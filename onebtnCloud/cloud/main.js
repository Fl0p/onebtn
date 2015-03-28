
// Use Parse.Cloud.define to define as many cloud functions as you want.
// For example:

var Push = Parse.Object.extend("Push");

Parse.Cloud.useMasterKey();

Parse.Cloud.define("hello", function(request, response) {
  response.success("Hello world!");
});


function createNewPush(userId) {
    
    
    console.log(" createNewPush " + userId);
    
    var pushInst = new Push();
    
    var acl = new Parse.ACL();
    acl.setPublicReadAccess(true);
    acl.setPublicWriteAccess(false);
    
    pushInst.setACL(acl);
    
    pushInst.set("value", 3);
    pushInst.set("userId", userId);
    
    pushInst.save();
    
    return pushInst;

}


Parse.Cloud.define("getPushes", function(request, response) {

                   console.log(" - - - - - - - ");
                   console.log(request);
                   
                   var userId = request.params.userId;

                   
                   if (userId == null) {
                    response.error("No user in request getPushes");
                    return;
                   }
                   
                   var query = new Parse.Query(Push);
                   query.equalTo("userId", userId);
                   query.first({
                              success: function(result) {
                               
                               var newPush = null;
                               
                               if (result == null) {
                                    console.log("push NOT Found");
                                    newPush = createNewPush(userId);
                               } else {
                                    console.log("push Found");
                                    newPush = result;
                               }

                               response.success(newPush);
                               
                               },
                              
                              error: function(error) {
                               
                               console.log(error);
                               response.error(error);
                               
                               }
                              });
                   

                   });
