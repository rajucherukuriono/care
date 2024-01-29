/*****************************************************************************************
Created By: John Wrightsman
Email: john.wrightsman@revelanttech.com
Created: 11/30/2020
Description: A class for fluently building and executing a SOQL query
Comments:

********************************************************************************************/
public inherited sharing class CCCQuery {
    String sObjectName;
    String orderByField;
    Boolean ascending = true;
    Integer recordLimit;
    List<String> relationshipNames;
    List<String> fields;
    List<String> criteria = new List<String>();

    public CCCQuery(String sObjectName) {
        this.sObjectName = sObjectName;
    }

    // Instantiates the CCCQuery instance and adds the FROM clause
    public static CCCQuery get(String sObjectName) {
        return new CCCQuery(sObjectName);
    }

    // Add a single field to the SELECT clause
    // All fields on the record will already be included in the result
    // so this method should be used for related object fields
    public CCCQuery field(String field) {
        if (this.fields == null) {
            this.fields = new List<String>();
        }
        this.fields.add(field);
        return this;
    }

    // Add a list of fields to the SELECT clause
    // All fields on the record will already be included in the result
    // so this method should be used for related object fields
    public CCCQuery fields(List<String> fields) {
        this.fields = fields;
        return this;
    }

    // Adds the ability to bring back all the fields on a lookup relationship.
    // Be aware that the maximum SOQL query length is 20,000 characters so it
    // is easy to go over this limit if the sObjects have a lot of fields.
    public CCCQuery add(String relationshipName) {
        if (this.relationshipNames == null) {
            this.relationshipNames = new List<String>();
        }
        this.relationshipNames.add(relationshipName);
        return this;
    }

    // Add a Boolean "equals" criterion to the WHERE clause
    public CCCQuery equals(String whereField, Boolean booleanValue) {
        this.criteria.add(whereField + ' = ' + String.valueOf(booleanValue));
        return this;
    }

    // Add a String "equals" criterion to the WHERE clause
    public CCCQuery equals(String whereField, String stringValue) {
        this.criteria.add(whereField + ' = \'' + stringValue + '\'');
        return this;
    }

    // Add a Decimal "equals" criterion to the WHERE clause
    public CCCQuery equals(String whereField, Decimal decimalValue) {
        this.criteria.add(whereField + ' = ' + String.valueOf(decimalValue));
        return this;
    }

    // Add an Integer "equals" criterion to the WHERE clause
    public CCCQuery equals(String whereField, Integer integerValue) {
        this.criteria.add(whereField + ' = ' + String.valueOf(integerValue));
        return this;
    }

    // Add an Id field criterion to the WHERE clause
    public CCCQuery equalsId(String idField) {
        this.criteria.add('Id = \'' + idField + '\'');
        return this;
    }

    // Add a Boolean "not equals" criterion to the WHERE clause
    public CCCQuery notEquals(String whereField, Boolean booleanValue) {
        this.criteria.add(whereField + ' != ' + String.valueOf(booleanValue));
        return this;
    }

    // Add a String "not equals" criterion to the WHERE clause
    public CCCQuery notEquals(String whereField, String stringValue) {
        this.criteria.add(whereField + ' != \'' + stringValue + '\'');
        return this;
    }

    // Add a Decimal "not equals" criterion to the WHERE clause
    public CCCQuery notEquals(String whereField, Decimal decimalValue) {
        this.criteria.add(whereField + ' != ' + String.valueOf(decimalValue));
        return this;
    }

    // Add an Integer "not equals" criterion to the WHERE clause
    public CCCQuery notEquals(String whereField, Integer integerValue) {
        this.criteria.add(whereField + ' != ' + String.valueOf(integerValue));
        return this;
    }

    // Add String "IN" criterion to the WHERE clause
    public CCCQuery includes(String whereInStringField, List<String> stringInValues) {
        this.criteria.add(whereInStringField + ' IN (\'' + String.join(stringInValues, '\', \'') + '\')');
        return this;
    }

    // Add String "IN" criterion to the WHERE clause
    public CCCQuery includes(String whereInStringField, Set<String> stringInValuesSet) {
        List<String> stringInValues = new List<String>();
        stringInValues.addAll(stringInValuesSet);
        this.criteria.add(whereInStringField + ' IN (\'' + String.join(stringInValues, '\', \'') + '\')');
        return this;
    }

    // Add String "NOT IN" criterion to the WHERE clause
    public CCCQuery notIncludes(String whereNotInStringField, List<String> stringNotInValues) {
        this.criteria.add(whereNotInStringField + ' NOT IN (\'' + String.join(stringNotInValues, '\', \'') + '\')');
        return this;
    }

    // Add String "NOT IN" criterion to the WHERE clause
    public CCCQuery notIncludes(String whereNotInStringField, Set<String> stringNotInValuesSet) {
        List<String> stringNotInValues = new List<String>();
        stringNotInValues.addAll(stringNotInValuesSet);
        this.criteria.add(whereNotInStringField + ' NOT IN (\'' + String.join(stringNotInValues, '\', \'') + '\')');
        return this;
    }

    // Add the ORDER BY clause
    public CCCQuery order(String orderByField) {
        this.orderByField = orderByField;
        return this;
    }

    // Sets order to DESC (default is ASC)
    public CCCQuery descending() {
        this.ascending = false;
        return this;
    }

    // Sets a record limit
    public CCCQuery limitTo(Integer recordLimit) {
        this.recordLimit = recordLimit;
        return this;
    }

    // Builds a list of accessible field names on the SObject
    private Set<String> getFields(String sObjectName) {
        Set<String> fields = new Set<String>();
        Map<String, Schema.SObjectField> fMap = Schema.getGlobalDescribe().get(sObjectName.toLowerCase()).getDescribe().fields.getMap();

        for (Schema.SObjectField ft : fMap.values()){ // loop through all field tokens (ft)
            Schema.DescribeFieldResult dfr = ft.getDescribe();
            System.debug('@@@ dfr name:' + dfr.getName() + '  isAccessible:' + dfr.isAccessible() + '  getType:' + dfr.getType());
            if (dfr.isAccessible() && dfr.getType() != Schema.DisplayType.LOCATION) {
                fields.add(dfr.getName());
            }
        }

        return fields;
    }

    private Set<String> getRelationShipFields() {
        Set<String> fields = new Set<String>();

        if (this.relationshipNames != null) {
            for (String relName : relationshipNames) {
                String prefix = relName.replace('__c', '__r');
                for (String fieldName : getFields(relName)) {
                    fields.add(prefix + '.' + fieldName);
                }
            }
        }

        return fields;
    }

    // Builds a SOQL query based on the setup
    public String buildQuery() {
        // Initially store fields in a set so that there are no duplicate field names
        Set<String> queryFieldsSet = getFields(this.sObjectName);
        if (this.fields != null) {
            queryFieldsSet.addAll(this.fields);
        }
        queryFieldsSet.addAll(getRelationShipFields());

        // Add fields
        List<String> queryFields = new List<String>(queryFieldsSet);

        // SOQL Query
        String query = 'SELECT ' + String.join(queryFields, ',') + ' FROM ' + this.sObjectName;

        if (this.criteria.size() > 0) {
            query += ' WHERE ' + String.join(this.criteria,' AND ');
        }

        if (this.orderByField != null) {
            query += ' ORDER BY ' + this.orderByField + (ascending ? '' : ' DESC');
        }

        if (this.recordLimit != null) {
            query += ' LIMIT ' + this.recordLimit;
        }

        if (query.length() > 20000) {
            throw new QueryException('The SOQL query is longer than 20,000 characters.');
        }
System.debug('@@@ query:' + query);
        return query;
    }

    // Builds and runs the SOQL query and returns the list of SObjects
    public List<sObject> all() {
        return Database.query(buildQuery());
    }

    // Builds and runs the SOQL query and returns a map of the object
    // using the record Id as the key.
    // Note: The field specified must either be a string type or convertable to a string
    public Map<String, sObject> toMap() {
        return toMap('Id');
    }

    // Builds and runs the SOQL query and returns a map of the object
    // using the specified fieldName as the key.
    // Note: The field specified must either be a string type or convertable to a string
    public Map<String, sObject> toMap(String fieldName) {
        Map<String, sObject> recordMap = new Map<String, sObject>();
        for (sObject record : all()) {
            recordMap.put(String.valueOf(record.get(fieldName)), record);
        }
        return recordMap;
    }

    // Builds and runs the SOQL query and returns a map of a List of objects
    // using the specified fieldName as the key.
    // Use this method if the key you are using will map to multiple objects
    // Note: The field specified must either be a string type or convertable to a string
    public Map<String, List<sObject>> toMapMultiple(String fieldName) {
        Map<String, List<sObject>> recordMap = new Map<String, List<sObject>>();
        for (sObject record : all()) {
            List<sObject> values = new List<sObject>();
            String key = String.valueOf(record.get(fieldName));
            if (recordMap.containsKey(key)) {
                values = recordMap.get(key);
            }
            values.add(record);
            recordMap.put(key, values);
        }
        return recordMap;
    }

    // Builds and runs the SOQL query with a limit and returns the list of SObjects
    public List<sObject> some(Integer recordLimit) {
        this.recordLimit = recordLimit;
        return Database.query(buildQuery());
    }

    // Builds and runs the SOQL query and returns a single SObject
    public sObject one() {
        this.recordLimit = 1;
        List<sObject> records = all();
        if (records.size() > 0) {
            return records[0];
        }
        return null;
    }

}