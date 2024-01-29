global class localDebug
{
 	global class debug implements BREeze.processRules.customDebug
    {
    	public string pad = '-----Debug----- ';
    	
        public void info(string debugString)
        {
			system.debug(pad + debugString);	
        }
    }
}