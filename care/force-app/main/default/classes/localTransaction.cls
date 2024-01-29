global class localTransaction
{
 	global class debug implements BREeze.processRules.customDebug
    {
    	public string pad = '-----Transaction----- ';
    	
        public void info(string debugString)
        {
			system.debug(pad + debugString);	
        }
    }
}