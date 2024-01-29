global class localPerformance
{
 	global class debug implements BREeze.processRules.customDebug
    {
    	public string pad = '-----Performance----- ';
    	
        public void info(string debugString)
        {
			system.debug(pad + debugString);	
        }
    }
}