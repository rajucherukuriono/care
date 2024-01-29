@isTest(seeAlldata=false)
private class local_Test 
{
	public testmethod static void localDebug() 
	{
		boolean pass = true;	
	
		try
		{
			localDebug.debug d = new localDebug.debug();
			d.info('test123');
		}
		catch (Exception e)
		{
			pass = false;
		}
		
	 	system.assertEquals(pass,true);
	}
	
	public testmethod static void localInformation() 
	{
		boolean pass = true;	
	
		try
		{
			localInformation.debug d = new localInformation.debug();
			d.info('test123');
		}
		catch (Exception e)
		{
			pass = false;
		}
		
	 	system.assertEquals(pass,true);
	}
	
	public testmethod static void localTransaction() 
	{
		boolean pass = true;	
	
		try
		{
			localTransaction.debug d = new localTransaction.debug();
			d.info('test123');
		}
		catch (Exception e)
		{
			pass = false;
		}
		
	 	system.assertEquals(pass,true);
	}
	
	public testmethod static void localPerformance() 
	{
		boolean pass = true;	
	
		try
		{
			localPerformance.debug d = new localPerformance.debug();
			d.info('test123');
		}
		catch (Exception e)
		{
			pass = false;
		}
		
	 	system.assertEquals(pass,true);
	}
	
	
	
	
	
	
}