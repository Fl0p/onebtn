
// Use Parse.Cloud.define to define as many cloud functions as you want.
// For example:

var Push = Parse.Object.extend("Push");

Parse.Cloud.useMasterKey();

Parse.Cloud.define("hello", function(request, response) {
  response.success("Hello world!");
});


function createNewPush() {
    
    var pushInst = new Push();
    
    var acl = new Parse.ACL();
    acl.setPublicReadAccess(true);
    acl.setPublicWriteAccess(false);
    
    pushInst.setACL(acl);
    
    pushInst.set("value", 3);
    
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
                   
                   query.first({
                              success: function(result) {
                               
                               if (result == null) {
                                    console.log("push NOT Found");
                               
                               } else {
                               
                                    console.log("push Found");
                               }

                               console.log(result);
                               response.success(result);
                               
                               
                               },
                              
                              error: function(error) {
                               
                               console.log(error);
                               response.error(error);
                               
                               }
                              });
                   

                   });
