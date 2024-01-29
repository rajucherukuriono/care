const MAP_SOURCE = 'postal-4-v2';
const MAP_SOURCE_LAYER = 'boundaries_postal_4';
const ZOOM_SELECT_LIMIT = 6.5;
const MILES_TO_METERS = 1609.34;
const ENTERPRISE_ZIP_PREFIX = 'USP4'; // The mapbox map stores zip codes with this prefix

let map, canvas, mapContextMenu, marker;
let debounceTimeoutId;
let selectedPostalCodes = new Set();
let allowEdit = true; // TODO: default to false and pass this in via init message
let selectModes = Object.freeze({ add: 'add', remove: 'remove' });
let contextMenuEnabled = true;

const normalPaintSetting = {
    'fill-outline-color': '#000',
    'fill-color': '#27A8E0',
    'fill-opacity': 0
}

const highlightedPaintSetting = {
    'fill-outline-color': '#000',
    'fill-color': '#27A8E0',
    'fill-opacity': 0.8,
    'fill-antialias': true
}

const selectedPaintSetting = {
    'fill-outline-color': '#000',
    'fill-color': '#27A8E0',
    'fill-opacity': 0.5
};


function init(message) {
    mapboxgl.accessToken = mapBoxApiKey;

    map = new mapboxgl.Map({
        container: 'map',
        style: 'mapbox://styles/mapbox/streets-v11', // stylesheet location
        center: [centerLng, centerLat], // starting position [lng, lat]
        minZoom: 1,
        zoom: initialZoom, // starting zoom level
        boxZoom: false, // Disable default box zooming so we can create the box select
        pitchWithRotate: false,
        attributionControl: false,
        dragRotate: false,
        touchZoomRotate: false,
        preserveDrawingBuffer: true
    });

    canvas = map.getCanvasContainer();

    // Create a marker to indicate the account location
    createMarker(centerLng, centerLat);

    // Define mile-radius radio buttons
    let radioButtonsHTML = [1, 3, 5, 7, 10].reduce((html, mileRange) => {
        return html + `
            <span class="slds-button slds-radio_button" onmouseover="showRadius(this, ${mileRange})" onmouseout="hideRadius(this)" onclick="selectRadius(this, ${mileRange})">
                <input type="radio" name="radio" id="miles_${mileRange}" value="${mileRange}" />
                <label class="slds-radio_button__label" for="miles_${mileRange}">
                    <span class="slds-radio_faux">${mileRange}</span>
                </label>
            </span>
        `;
    }, '');

    // Create map context menu
    mapContextMenu = new mapboxgl.Popup({
        anchor: 'top',
        closeButton: true,
        maxWidth: '400px'
    }).setHTML(`
        <fieldset class="slds-form-element">
            <legend class="slds-form-element__legend slds-form-element__label">Select all postal codes within <i>x</i> miles:</legend>
            <div class="slds-form-element__control">
                <div class="slds-radio_button-group">
                    ${radioButtonsHTML}
                </div>
            </div>
        </fieldset>
    `);

    // Map event handlers
    map.on('load', () => {
        // Add sources and layers

        map.addSource(MAP_SOURCE, {
            type: 'vector',
            url: 'mapbox://mapbox.enterprise-boundaries-p4-v2'
        });

        map.addLayer({
            'id': 'zips',
            'type': 'fill',
            'source': MAP_SOURCE,
            'source-layer': MAP_SOURCE_LAYER,
            'paint': normalPaintSetting
        });

        map.addLayer({ // used for highlighting postal code on mouse hover
            'id': 'zips-highlighted',
            'type': 'fill',
            'source': MAP_SOURCE,
            'source-layer': MAP_SOURCE_LAYER,
            'paint': highlightedPaintSetting,
            'filter': ['in', 'id', '']
        });

        map.addLayer({ // used for displaying selected postal codes
            'id': 'zips-selected',
            'type': 'fill',
            'source': MAP_SOURCE,
            'source-layer': MAP_SOURCE_LAYER,
            'paint': selectedPaintSetting,
            'filter': ['in', 'id', '']
        });

        map.addLayer({ // used for displaying postal code labels
            'id': 'zip-labels',
            'type': 'symbol',
            'source': MAP_SOURCE,
            'source-layer': MAP_SOURCE_LAYER,
            'layout': {
                'text-field': ['slice', ['get', 'id'], 4],
                'text-anchor': 'center',
                'text-justify': 'auto',
                'text-size': 14
            },
            'paint': {
                'text-opacity': .75
            }
        });

        map.addLayer({ // polygon layer for geojson circle
            id: 'polygon',
            type: 'fill',
            source: {
                type: 'geojson',
                data: {
                    type: 'Feature',
                    geometry: {
                        type: 'Polygon',
                        coordinates: [
                            [
                            ]
                        ]
                    }
                }
            },
            layout: {},
            paint: {
                'fill-color': 'blue',
                'fill-opacity': 0.3
            }
        });

        // Add geocoding control
        map.addControl(
            new MapboxGeocoder({
                accessToken: mapBoxApiKey,
                mapboxgl: mapboxgl,
                collapsed: true,
                countries: 'us',
                minLength: 3,
                enableEventLogging: false
            })
        );

        let start; // holds the starting xy coordinates when `mousedown` occured
        let current; // holds the current xy coordinates when `mousemove` or `mouseup` occurs
        let box; // holds the draw box element.

        if (allowEdit) {
            canvas.addEventListener('mousedown', mouseDown, true);
        }

        // Return the xy coordinates of the mouse position
        function getMousePos(e) {
            let rect = canvas.getBoundingClientRect();
            return new mapboxgl.Point(
                e.clientX - rect.left - canvas.clientLeft,
                e.clientY - rect.top - canvas.clientTop
            );
        }

        // Checks whether SHIFT ('add' mode) or CTRL ('remove' mode) are pressed.
        // If neither are pressed, null is returned.
        function getSelectMode(e) {
            let selectMode;
            if (e.shiftKey && !e.ctrlKey) {
                selectMode = selectModes.add;
            }
            if (!e.shiftKey && e.ctrlKey) {
                selectMode = selectModes.remove;
            }
            return selectMode;
        }
        function mouseDown(e) {
            // Continue the rest of the function if the shiftkey is pressed.
            if (!((e.shiftKey || e.ctrlKey) && e.button === 0)) return;

            // if (map.getZoom() < ZOOM_SELECT_LIMIT) return;

            // Disable default drag zooming when the shift key is held down.
            map.dragPan.disable();

            // Call functions for the following events
            document.addEventListener('mousemove', onMouseMove);
            document.addEventListener('mouseup', onMouseUp);
            document.addEventListener('keydown', onKeyDown);

            // Capture the first xy coordinates
            start = getMousePos(e);
        }

        function onMouseMove(e) {
            // Capture the ongoing xy coordinates
            current = getMousePos(e);

            // Append the box element if it doesnt exist
            if (!box) {
                box = document.createElement('div');
                box.classList.add('boxdraw');
                canvas.appendChild(box);
            }

            let minX = Math.min(start.x, current.x),
                maxX = Math.max(start.x, current.x),
                minY = Math.min(start.y, current.y),
                maxY = Math.max(start.y, current.y);

            // Adjust width and xy position of the box element ongoing
            let pos = 'translate(' + minX + 'px,' + minY + 'px)';
            box.style.transform = pos;
            box.style.WebkitTransform = pos;
            box.style.width = maxX - minX + 'px';
            box.style.height = maxY - minY + 'px';
            if (getSelectMode(e) === selectModes.add) {
                box.style.border = '1px solid black';
            } else {
                box.style.border = '1px solid blue';
            }
        }

        function onMouseUp(e) {
            let selectMode = getSelectMode(e);
            if (selectMode === selectModes.add || selectMode === selectModes.remove) {
                finish([start, getMousePos(e)], selectMode);
            }
        }

        function onKeyDown(e) {
            // If the ESC key is pressed
            if (e.keyCode === 27) finish();
        }

        function finish(bbox, selectMode) {
            // Remove these events now that finish has been called.
            document.removeEventListener('mousemove', onMouseMove);
            document.removeEventListener('keydown', onKeyDown);
            document.removeEventListener('mouseup', onMouseUp);

            if (box) {
                box.parentNode.removeChild(box);
                box = null;
            }

            if (bbox) {
                toggleFeaturesWithinBoundingBox(bbox, selectMode);
            }

            map.dragPan.enable();
        }

        map.on('mousemove', e => {
            try {
                if (map.getZoom() > ZOOM_SELECT_LIMIT) {
                    let features = map.queryRenderedFeatures(e.point, { layers: ['zips'] });
                    // Change the cursor style as a UI indicator.
                    map.getCanvas().style.cursor = (features.length) ? 'pointer' : '';
                    if (!features.length) {
                        highlightPostalCodes();
                        return;
                    }

                    let feature = features[0];
                    let postalCode = feature.properties.id.substring(feature.properties.id.length - 5);
                    highlightPostalCodes(postalCode);
                } else {
                    map.getCanvas().style.cursor = '';
                }
            } catch (err) {
            }
        });

        map.on('click', e => {
            if (map.getZoom() > ZOOM_SELECT_LIMIT) {
                let features = map.queryRenderedFeatures(e.point, { layers: ['zips'] });
                if (!features.length) {
                    return;
                }

                try {
                    let feature = features[0];
                    let zip = feature.properties.id.substring(feature.properties.id.length - 5);
                    togglePostalCode(zip);
                } catch (err) { }
                // let zip = features[0].properties['ZCTA5CE10'];
                // togglePostalCode(zip);
            }
        });

        if (allowEdit) {
            map.on('contextmenu', e => mapContextMenu.setLngLat(e.lngLat).addTo(map));
        }

        // Set the incoming postal codes as already selected and highlight them
        let postalCodes = message.locationRecord.Postal_Codes__c ? message.locationRecord.Postal_Codes__c.split(', ') : [];
        selectedPostalCodes = new Set(postalCodes);
        map.setFilter('zips-selected', ['in', 'id'].concat(postalCodes.map(p => ENTERPRISE_ZIP_PREFIX + p)));
    });

}

function setCenter(message) {
    // Set the map's center coordinates
    map.setCenter([
        message.locationRecord.Geolocation_Coordinates__longitude__s,
        message.locationRecord.Geolocation_Coordinates__latitude__s
    ]);

    createMarker(
        message.locationRecord.Geolocation_Coordinates__longitude__s,
        message.locationRecord.Geolocation_Coordinates__latitude__s
    );
}

function createMarker(lng, lat) {
    marker = new mapboxgl.Marker()
        .setLngLat([lng, lat])
        .addTo(map);
}

function highlightPostalCodes(postalCodes) {
    if (postalCodes) {
        if (!Array.isArray(postalCodes)) {
            postalCodes = [postalCodes];
        }
        map.setFilter('zips-highlighted', ['in', 'id'].concat(postalCodes.map(p => ENTERPRISE_ZIP_PREFIX + p)));
    } else {
        // If no postal code is sent, clear the highlighted layer
        map.setFilter('zips-highlighted', ['in', 'id', '']);
    }
}

function togglePostalCode(postalCode) {
    if (selectedPostalCodes.has(postalCode)) {
        selectedPostalCodes.delete(postalCode);
    } else {
        selectedPostalCodes.add(postalCode);
    }

    map.setFilter('zips-selected', ['in', 'id'].concat([...selectedPostalCodes].map(p => ENTERPRISE_ZIP_PREFIX + p)));
    // debounce(updateLightningContainer, 500);
    updateLightningContainer();
}

function toggleFeaturesWithinBoundingBox(boundingBox, selectMode) {
    let features = map.queryRenderedFeatures(boundingBox, { layers: ['zips'] });
    let featuresLength = features.length;
    let postalCodes = [];
    for (let i = 0; i < featuresLength; i++) {
        let feature = features[i];
        let postalCode = feature.properties.id.substring(feature.properties.id.length - 5);
        postalCodes.push(postalCode);
    }
    if (postalCodes.length > 0) {
        for (let i = 0; i < postalCodes.length; i++) {
            if (selectMode === selectModes.add) {
                selectedPostalCodes.add(postalCodes[i]);
            } else {
                selectedPostalCodes.delete(postalCodes[i]);
            }
        }
        let allSelectedPostalCodes = [...selectedPostalCodes].map(p => ENTERPRISE_ZIP_PREFIX + p);
        map.setFilter('zips-selected', ['in', 'id'].concat(allSelectedPostalCodes));
        updateLightningContainer();
    }
}


function showRadius(container, radiusMiles) {
    container.getElementsByTagName('input')[0].checked = true;
    let lngLat = mapContextMenu.getLngLat();
    map.getSource('polygon').setData(createGeoJSONCircle(lngLat, radiusMiles).data);
}

function hideRadius(container) {
    container.getElementsByTagName('input')[0].checked = false;
    map.getSource('polygon').setData(createGeoJSONCircle({ lat: 0, lng: 0 }, 0).data);
}

// Selects all districts within a radius from a Lng/Lat
function selectRadius(container, radiusInMiles) {
    let lngLat = mapContextMenu.getLngLat();
    let km = radiusInMiles * MILES_TO_METERS;
    let boundingBox = lngLat.toBounds(km).toArray();

    // convert bounding lat/lng coordinates to pixel coordinates
    boundingBox = boundingBox.map(coord => map.project(coord))

    toggleFeaturesWithinBoundingBox(boundingBox, selectModes.add);

    // remove context menu and geojson circle
    mapContextMenu.remove()
    container.getElementsByTagName('input')[0].checked = false;
    map.getSource('polygon').setData(createGeoJSONCircle({ lat: 0, lng: 0 }, 0).data);
}

// Generates a geojson circle
function createGeoJSONCircle(lngLat, radiusInMiles, points) {
    points = points ? points : 64;
    let km = radiusInMiles * 1.6094;
    let ret = [];
    let distanceX = km / (111.320 * Math.cos(lngLat.lat * Math.PI / 180));
    let distanceY = km / 110.574;
    let theta, x, y;

    for (let i = 0; i < points; i++) {
        theta = (i / points) * (2 * Math.PI);
        x = distanceX * Math.cos(theta);
        y = distanceY * Math.sin(theta);
        ret.push([lngLat.lng + x, lngLat.lat + y]);
    }
    ret.push(ret[0]);

    return {
        'type': 'geojson',
        'data': {
            'type': 'FeatureCollection',
            'features': [{
                'type': 'Feature',
                'geometry': {
                    'type': 'Polygon',
                    'coordinates': [ret]
                }
            }]
        }
    };
};

function updateLightningContainer() {
    sendMessage({ messageType: 'updateselectedPostalCodes', message: { postalCodes: [...selectedPostalCodes] } });
}

function debounce(callback, delay) {
    return (...args) => {
        clearTimeout(debounceTimeoutId);
        debounceTimeoutId = setTimeout(() => callback(...args), delay);
    }
}
