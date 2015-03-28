
// Use Parse.Cloud.define to define as many cloud functions as you want.
// For example:

var Push = Parse.Object.extend("Push");

Parse.Cloud.useMasterKey();

Parse.Cloud.define("hello", function(request, response) {
  response.success("Hello world!");
});


function sendPush(userId) {
    console.log(" sendPush " + userId);
    
    Parse.Push.send({
                    channels: ["GLOBAL"],
                    push_time: new Date(new Date().getTime() + 5000),
                    data: {
                    "alert": "The push",
                    "sound": "default",
                    "title": "OneButton"
                    }
                    }, {
                    success: function() {
                    // Push was successful
                        console.log(" Push was successful from " + userId);
                    },
                    error: function(error) {
                    // Handle error
                        console.log(" Push was not successful " + error);
                    }
                    });
     console.log(" sendPush ..." );
    
}

function createNewPush(userId) {
    
    
    console.log(" createNewPush " + userId);
    
    var pushInst = new Push();

    var acl = new Parse.ACL();

    acl.setPublicReadAccess(true);
    acl.setPublicWriteAccess(false);

    pushInst.setACL(acl);

    pushInst.set("value", 30);
    pushInst.set("userId" , userId);

    pushInst.save();
    
    return pushInst;

}


Parse.Cloud.define("getPushes", function(request, response) {

                   console.log(" - - - - - - - ");
                   console.log(" - getPushes - ");
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
                               
                               console.log("8");
                               response.success(newPush.get("value"));
                               console.log("9");                               
                               },
                              
                              error: function(error) {
                               
                               console.log(error);
                               response.error(error);
                               
                               }
                              });
                   

                   });



Parse.Cloud.define("sendPush", function(request, response) {
                   
                   console.log(" - - - - - - - ");
                   console.log(" - sendPush - ");
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
                               
                               
                               if (result == null) {
                               console.log("push NOT Found");
                               response.error("NO pushes");
                               return;
                               }
                               
                               console.log("push Found");
                               var pushInst = result;
                               
                               sendPush(userId);
                               
                               var value = pushInst.get("value");
                               value--;
                               pushInst.set("value",value);
                               
                               pushInst.save();
                               
                               response.success(pushInst.get("value"));
                               

                               
                               },
                               
                               error: function(error) {
                               
                               console.log(error);
                               response.error(error);
                               
                               }
                               });
                   
                   
                   });
