
// Use Parse.Cloud.define to define as many cloud functions as you want.
// For example:
Parse.Cloud.define("hello", function(request, response) {
  response.success("Hello world!");
});


Parse.Cloud.define("getPushes", function(request, response) {

                   console.log(" - - - - - - - ");
                   console.log("getPushes");
                   
                   var Push = Parse.Object.extend("Push");
                   
                   
                   var pushInst = new Push();
                   pushInst.set("val", 3);
                   pushInst.save();
                   console.log(pushInst);
                   
                   
                   var query = new Parse.Query(Push);
                   
                   query.first({
                              success: function(results) {
                               console.log("push Found");
                               response.success(results);
                               
                               
                               },
                              
                              error: function(error) {
                               console.log("push not Found");
                               var newPush = new Push();
                               newPush.save();
                               
                               console.log(newPush);
                               
                               response.success(newPush);
                               
                               }
                              });
                   

                   });
