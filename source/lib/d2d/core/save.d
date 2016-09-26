module d2d.core.save;

import d2d.core;

/** 
    holds callable methods that save the instance
*/

/// executes a save 
/// Parameter: saveName = display name (not resource name!) of safe to store
void doSave(string saveName)
{
    auto root = Base.getService!Base("d2d.gameroot");
    JsonData d = JsonData.createNew("save." ~ saveName);
    d.data = Base.save(root);
    d.save();
}

/** executes a save restore
    Parameter: 
        saveName = display name of the save to store
        clearRoot = if the root (d2d.gameroot) should be cleared
*/
void doSaveRestore(string saveName, bool clearRoot=true)
{
    auto root = Base.getService!Base("d2d.gameroot");
    if(clearRoot) {
        root.children.clear();
    }
    
    JsonData d = Resource.create!JsonData("save." ~ saveName);
    root.restoreSave(d.data,root);
}