public class DataCategoryGroupStructureHelper {
    public static Map<String,String> generateDataCategoryNameToLabelMap(String objName){
        Map<String,String> dataCategoryNameToLabelMap = new Map<String,String>();
        
        List<DescribeDataCategoryGroupResult> describeCategoryResult;
        List<DescribeDataCategoryGroupStructureResult> describeCategoryStructureResult;
        try {
            //Making the call to the describeDataCategoryGroups to
            //get the list of category groups associated
            List<String> objType = new List<String>();
            objType.add(objName);
            describeCategoryResult = Schema.describeDataCategoryGroups(objType);
            
            //Creating a list of pair objects to use as a parameter
            //for the describe call
            List<DataCategoryGroupSobjectTypePair> pairs = 
                new List<DataCategoryGroupSobjectTypePair>();
            
            //Looping throught the first describe result to create
            //the list of pairs for the second describe call
            for(DescribeDataCategoryGroupResult singleResult : 
                describeCategoryResult){
                    DataCategoryGroupSobjectTypePair p =
                        new DataCategoryGroupSobjectTypePair();
                    p.setSobject(singleResult.getSobject());
                    p.setDataCategoryGroupName(singleResult.getName());
                    pairs.add(p);
                }
            
            //describeDataCategoryGroupStructures()
            describeCategoryStructureResult = 
                Schema.describeDataCategoryGroupStructures(pairs, false);
            
            //Getting data from the result
            for(DescribeDataCategoryGroupStructureResult singleResult : describeCategoryStructureResult){
                //Get name of the associated Sobject
                singleResult.getSobject();
                
                //Get the name of the data category group
                singleResult.getName();
                
                //Get the name of the data category group
                singleResult.getLabel();
                
                //Get the description of the data category group
                singleResult.getDescription();
                
                //Get the top level categories
                DataCategory [] toplevelCategories = 
                    singleResult.getTopCategories();
                
                //Recursively get all the categories
                List<DataCategory> allCategories = 
                    getAllCategories(toplevelCategories);
                
                for(DataCategory category : allCategories) {
                    dataCategoryNameToLabelMap.put(category.getName(),category.getLabel());
                    
                    //Get the name of the category
                    category.getName();
                    
                    //Get the label of the category
                    category.getLabel();
                    
                    //Get the list of sub categories in the category
                    DataCategory [] childCategories = 
                        category.getChildCategories();
                }
            }
        } catch (Exception e){
        }
        return dataCategoryNameToLabelMap;
    }
    
    private static DataCategory[] getAllCategories(DataCategory [] categories){
        if(categories.isEmpty()){
            return new DataCategory[]{};
                } else {
                    DataCategory [] categoriesClone = categories.clone();
                    DataCategory category = categoriesClone[0];
                    DataCategory[] allCategories = new DataCategory[]{category};
                        categoriesClone.remove(0);
                    categoriesClone.addAll(category.getChildCategories());
                    allCategories.addAll(getAllCategories(categoriesClone));
                    return allCategories;
                }
    }
}