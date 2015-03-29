
// Use Parse.Cloud.define to define as many cloud functions as you want.
// For example:

var Push = Parse.Object.extend("Push");
//var Installation = Parse.Object.extend("Installation");

Parse.Cloud.useMasterKey();

Parse.Cloud.define("hello", function(request, response) {
  response.success("Hello world!");
});



function incrementPush(userId) {
    
    console.log("incrementPush "+userId);
    
    if (userId == null) {
        console.log("No user in request getPushes");
        return;
    }
    
    
    var query = new Parse.Query(Push);
    query.equalTo("userId", userId);
    query.first({
                success: function(result) {
                
                    var pushInst = null;
                    
                    if (result == null) {
                        console.log("increment push NOT Found");
                        return;
                    } else {
                        console.log("increment push Found");
                        pushInst = result;
                    }
                
                    var value = pushInst.get("value");
                    value++;
                    pushInst.set("value", value);
                
                    pushInst.save();

                },
                
                error: function(error) {
                
                    console.log(error);
                
                }
        });

}

function sendPush(userId,toUserId) {
    
    console.log(" sendPush from " + userId + " to " + toUserId);
    

    var pushData = new Object();
//    pushData.alert = "The push";
//    pushData.title = "PUSH";
    
    var rand = Math.floor((Math.random() * 4) + 0);

    pushData.sound = "pushSound" + rand + ".wav";
//    pushData.sound = "silent.wav";
    
    pushData["content-available"] = 1;
    pushData.fromUser = userId;
    
    var pushChannels = ["GLOBAL"]
    
    if (toUserId == null) {
        //find random user
        console.log( " - find random user " + userId );
    
        incrementPush(userId);
        
        var q = new Parse.Query(Push);
        q.equalTo("userId", userId);
        q.first({
                    success: function(result) {
                        console.log(" OLOLOLOLO ");
                        console.log(" !!!!!! push Found" + result);
                    },
                    
                    error: function(error) {
                        console.log(" OLOLOLOLO ");
                        console.log(error);
                    
                    }
                });
        
        
        console.log("inst q"+q);
        
        
        //return;
    }
    
    
    
    if (toUserId != null) {
        console.log( " - send push to channel " + toUserId);
        pushChannels  = ["GLOBAL",toUserId];
        console.log( pushChannels );
        
        incrementPush(toUserId);
    }
    
    Parse.Push.send({
                    
                    channels: pushChannels,
                    push_time: new Date(new Date().getTime() + 5000),
                    data: pushData
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
                                   

                                   response.success(newPush.get("value"));

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
                   var toUserId = request.params.toUserId;
                   
                   
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
                               
                               sendPush(userId,toUserId);
                               
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
