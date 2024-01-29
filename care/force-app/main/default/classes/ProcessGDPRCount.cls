global class ProcessGDPRCount{
    webservice static void processGDPRCount(String mailIds){
        String[] mailArr=mailIds.split(',');
        String mailIdsArr='';
        for(integer i=0;i<mailArr.size();i++)
        {
            String str=mailArr[i];
            if(i==mailArr.size()-1) mailIdsArr=mailIdsArr+'\''+str+'\''; else mailIdsArr=mailIdsArr+'\''+str+'\',';
        }
        List<User> userList=[select id,firstname,lastname,email,name,username from user where email in :mailArr];
        String day=String.valueOf(Datetime.now().day()); 
        String month=String.valueOf(Datetime.now().month()); 
        String year=String.valueOf(Datetime.now().year()); 
        String hour = String.valueOf(Datetime.now().hour()); 
        String min = String.valueOf(Datetime.now().minute() ); 
        String ss = String.valueOf(Datetime.now().second()+10 ); 
        if(Integer.valueOf(ss)>59)   ss=String.valueOf(59); 
        BatchGDPRMemberRequestCount batchObj=new BatchGDPRMemberRequestCount(false,userList);
        //parse to cron expression 
        String nextFireTime = ss + ' ' + min + ' ' + hour + ' ' + day+ ' ' + month+' ' + '?  ' + year; 
        List<CronTrigger> cronObj=[SELECT CronExpression,CronJobDetailId,EndTime,Id,LastModifiedById,NextFireTime,OwnerId,PreviousFireTime,StartTime,State FROM CronTrigger where CronJobDetail.name='GDPR Count'];
        if(cronObj.size()>0)
            System.abortJob(cronObj[0].id);
        cronObj=[SELECT CronExpression,CronJobDetailId,EndTime,Id,LastModifiedById,NextFireTime,OwnerId,PreviousFireTime,StartTime,State FROM CronTrigger where CronJobDetail.name='GDPR Count'];
        if(cronObj.size()==0)
            System.schedulebatch(new BatchGDPRMemberRequestCount(false,userList),'GDPR Count',1,2000);
    }
}