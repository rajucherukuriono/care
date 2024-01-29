global class localInformation
{
 	global class debug implements BREeze.processRules.customDebug
    {
    	public string pad = '-----Information----- ';
    	
        public void info(string debugString)
        {
			system.debug(pad + debugString);	
        }
    }
}