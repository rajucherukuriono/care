import { LightningElement, api } from 'lwc';
import hc_log_in from '@salesforce/label/c.HC_Log_In';
import hc_join_now from '@salesforce/label/c.HC_Join_Now';
import hc_upgrade from '@salesforce/label/c.HC_Upgrade';
import { buildLoginUrl } from 'c/linkHelperService';


export default class ExtendedMenu extends LightningElement {
    @api isMobile;
    @api showEM = false;
    @api activeMenu =  'childCare';
    emLauncherClasses = 'jss13 DW';
    buttonClasses = 'DW';
    contentClasses = 'jss53 DW';
    contentClassesMW = 'jss53 MW';
    firstLevelMenuMWClassesClosed = 'jss186 jss187';
    firstLevelMenuMWClassesOpen = 'jss186 jss188';
    secondLevelMenuMWClasses = 'jss16 MW'
    firstLevelMenuSVGIconClass = 'MuiSvgIcon-root SVGCounter';
    @api firstLevelMenuSVGIconCounter = 1;
    @api secondLevelMenuHeader;
    @api mobileNavOpen;
    @api mobileNavOpenSecondLevel;

    @api communitySettings = {};
    @api localeSettings = {};
    @api showJoinNowLink = false;
    @api showUpgradeLink = false;
    @api showLoginLink = false;    
    label = {hc_log_in, hc_join_now, hc_upgrade};    

    get isEnUs(){
        return (window.localStorage.getItem('locale') === 'en_US');
    }
    
    get firstLevelMenuSVGIcon(){
        // these SVG Icons don't display properly, unless their class is changes.  On the Care.com side that was happening automatically via their framework.  I'm handling it artificially with this counter.
        return this.firstLevelMenuSVGIconClass + this.firstLevelMenuSVGIconCounter++;
    }

    get emClass(){
        return this.showEM === true ? this.emLauncherClasses + ' open' : this.emLauncherClasses;
    }

    get emLauncherIconName() {
        return this.showEM ? 'utility:close' : 'utility:threedots_vertical';
    }
    
    get ariaExpanded(){
        return this.showEM === true ? 'true' : 'false';
    }

    get childCareSelected(){
        return this.activeMenu === 'childCare' ? 'true' : 'false';
    }

    get tutoringSelected(){
        return this.activeMenu === 'tutoring' ? 'true' : 'false';
    }
    
    get seniorCareSelected(){
        return this.activeMenu === 'seniorCare' ? 'true' : 'false';
    }
    
    get petCareSelected(){
        return this.activeMenu === 'petCare' ? 'true' : 'false';
    }

    get housekeepingSelected(){
        return this.activeMenu === 'housekeeping' ? 'true' : 'false';
    }
    
    get jobsButtonSelected(){
        return this.activeMenu === 'jobs' ? 'true' : 'false';
    }


    get childCareButtonClass(){
        return this.activeMenu === 'childCare' ? this.buttonClasses + ' active' : this.buttonClasses;
    }
    
    get tutoringButtonClass(){
        return this.activeMenu === 'tutoring' ? this.buttonClasses + ' active' : this.buttonClasses;
    }
    
    get seniorCareButtonClass(){
        return this.activeMenu === 'seniorCare' ? this.buttonClasses + ' active' : this.buttonClasses;
    }
    
    get petCareButtonClass(){
        return this.activeMenu === 'petCare' ? this.buttonClasses + ' active' : this.buttonClasses;
    }

    get housekeepingButtonClass(){
        return this.activeMenu === 'housekeeping' ? this.buttonClasses + ' active' : this.buttonClasses;
    }
    
    get jobsButtonClass(){
        return this.activeMenu === 'jobs' ? this.buttonClasses + ' active' : this.buttonClasses;
    }


    get childCareContentClass(){
        return this.activeMenu === 'childCare' ? this.contentClasses + ' open' : this.contentClasses;
    }
    
    get tutoringContentClass(){
        return this.activeMenu === 'tutoring' ? this.contentClasses + ' open' : this.contentClasses;
    }
    
    get seniorCareContentClass(){
        return this.activeMenu === 'seniorCare' ? this.contentClasses + ' open' : this.contentClasses;
    }
    
    get petCareContentClass(){
        return this.activeMenu === 'petCare' ? this.contentClasses + ' open' : this.contentClasses;
    }

    get housekeepingContentClass(){
        return this.activeMenu === 'housekeeping' ? this.contentClasses + ' open' : this.contentClasses;
    }
    
    get jobsContentClass(){
        return this.activeMenu === 'jobs' ? this.contentClasses + ' open' : this.contentClasses;
    }
    
    get childCareContentClassMW(){
        return this.activeMenu === 'childCare' ? this.contentClassesMW + ' open' : this.contentClassesMW;
    }
    
    get tutoringContentClassMW(){
        return this.activeMenu === 'tutoring' ? this.contentClassesMW + ' open' : this.contentClassesMW;
    }
    
    get seniorCareContentClassMW(){
        return this.activeMenu === 'seniorCare' ? this.contentClassesMW + ' open' : this.contentClassesMW;
    }
    
    get petCareContentClassMW(){
        return this.activeMenu === 'petCare' ? this.contentClassesMW + ' open' : this.contentClassesMW;
    }

    get housekeepingContentClassMW(){
        return this.activeMenu === 'housekeeping' ? this.contentClassesMW + ' open' : this.contentClassesMW;
    }
    
    get jobsContentClassMW(){
        return this.activeMenu === 'jobs' ? this.contentClassesMW + ' open' : this.contentClassesMW;
    }
    
    get firstLevelMenuMWClass(){
        return this.mobileNavOpen === true ? this.firstLevelMenuMWClassesOpen : this.firstLevelMenuMWClassesClosed;
    }

    get secondLevelMenuMWClass(){
        return this.mobileNavOpenSecondLevel === true ? this.secondLevelMenuMWClasses + ' open' : this.secondLevelMenuMWClasses;
    }

    get secondLevelMenuHeader(){
        if (this.activeMenu === 'childCare') return 'Child Care';
        if (this.activeMenu === 'tutoring') return 'Tutoring';
        if (this.activeMenu === 'seniorCare') return 'Senior Care';
        if (this.activeMenu === 'petCare') return 'Pet Care';
        if (this.activeMenu === 'housekeeping') return 'Housekeeping';
        if (this.activeMenu === 'jobs') return 'Jobs';
        else return '';
    }

    get showApplyToJobsLink(){
        // Only show link if it's defined in locale settings
        if (this.localeSettings !== undefined && this.localeSettings.Apply_to_Jobs__c !== undefined) return true;
        return false; 

    }

    get loginUrl(){
        return buildLoginUrl(this.localeSettings.Login__c);
    }

    connectedCallback(){
//        console.log('isMobile: ' + this.isMobile);
//        console.log('this.activeMenu: ' + this.activeMenu);
    }


    handleEMClick(){
        this.showEM = !this.showEM;
    
    }

    
    handleChildCareClick(){
        this.activeMenu = 'childCare';
        this.handleClickHelper();
    }

    handleTutoringClick(){
        this.activeMenu = 'tutoring';
        this.handleClickHelper();
    }

    handleSeniorCareClick(){
        this.activeMenu = 'seniorCare';
        this.handleClickHelper();
    }

    handlePetCareClick(){
        this.activeMenu = 'petCare';
        this.handleClickHelper();
    }

    handleHousekeepingClick(){
        this.activeMenu = 'housekeeping';
        this.handleClickHelper();
    }

    handleJobsClick(){
        this.activeMenu = 'jobs';
        this.handleClickHelper();

    }

    handleClickHelper(){
        this.firstLevelMenuSVGIconCounter++;
        if (this.mobileNavOpen){this.mobileNavOpenSecondLevel = true;}
    }

    handleMobileNavMenuIconClick(){
        this.mobileNavOpen = !this.mobileNavOpen;
//        console.log('this.mobileNavOpen: ' + this.mobileNavOpen);
    }

    handleBackClick(){
        this.activeMenu = '';
        this.mobileNavOpenSecondLevel = false;
    }

    handleMobileNavMenuCloseButton(){
        this.mobileNavOpen = false;
    }
}