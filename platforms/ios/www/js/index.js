/*
 * Licensed to the Apache Software Foundation (ASF) under one
 * or more contributor license agreements.  See the NOTICE file
 * distributed with this work for additional information
 * regarding copyright ownership.  The ASF licenses this file
 * to you under the Apache License, Version 2.0 (the
 * "License"); you may not use this file except in compliance
 * with the License.  You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing,
 * software distributed under the License is distributed on an
 * "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 * KIND, either express or implied.  See the License for the
 * specific language governing permissions and limitations
 * under the License.
 */
window.onerror = function (message, url, lineNumber) {
    console.log("Error: " + message + " in " + url + " at line " + lineNumber);
}
var stateMachine = { previousState: "n/a", currentState: "n/a" };
var app = {

// Application Constructor
    initialize: function () {
       
        this.bindEvents();
    },
// Bind Event Listeners
//
// Bind any events that are required on startup. Common events are:
// 'load', 'deviceready', 'offline', and 'online'.
    bindEvents: function () {

        document.addEventListener('deviceready', this.onDeviceReady, false);
    },
// deviceready Event Handler
//
// The scope of 'this' is the event. In order to call the 'receivedEvent'
// function, we must explicity call 'app.receivedEvent(...);'
    onDeviceReady: function () {

       // app.receivedEvent('deviceready');
        console.log("onDeviceReady");
        estimoteBeacons.getMyDeviceToken(function(data){
                                     
            console.log(data);
                                                     });
        estimoteBeacons.startRangingBeaconsInRegion(function(){
      //  estimoteBeacons.startMonitoringForRegion(1,1,"test",function () {

            setInterval(function () {
                estimoteBeacons.getBeacons(function (data) {

                   //  console.log(data);
                    if (data.length > 0) {
                        var closestBeacon = data[0];
                        //  {"isConnected":false,"proximity":1,"description":"<ESTBeacon: 0x16d5d680>","debugDescription":"<ESTBeacon: 0x16d5d680>","rssi":-36,"accuracy":0.05509005440313974,"proximityUUID":"B9407F30-F5F8-466E-AFF9-25556B57FE6D","minor":10,"major":30}
                
                        var proximityUUID = closestBeacon["proximityUUID"];
                      //  console.log(proximityUUID);
                        $("#closetBeacon").html("beacon <br/> proximityUUID : " + closestBeacon["proximityUUID"] + "<br/> proximity : " + closestBeacon["proximity"]);
                        stateMachine.previousState = stateMachine.currentState;
                        var proximity = closestBeacon["proximity"];
                        switch (proximity) {
                            case 0: //CLProximityUnknown:
                                stateMachine.currentState = "u"; // unknown
                                break;
                            case 1 : //CLProximityImmediate
                                stateMachine.currentState = "i"; // immediate
                                break;
                            case 2 : //CLProximityNear:
                                stateMachine.currentState = "n"; // near
                                break;
                            case 3 : //CLProximityFar:
                                stateMachine.currentState = "f"; // far
                                break;

                            default:
                                break;
                        }
                        var curr=stateMachine.currentState;
                        var prev=stateMachine.previousState;
                        if(curr!=prev)
                        {
                    
                           $("#closetBeacon").append("<br/> State Changed");
                        }
                    }
                    else{
                         $("#closetBeacon").html("out of range");                   
                    }
                });
            }, 1000);
        });

    },
// Update DOM on a Received Event
    receivedEvent: function (id) {
        var parentElement = document.getElementById(id);
        var listeningElement = parentElement.querySelector('.listening');
        var receivedElement = parentElement.querySelector('.received');

        listeningElement.setAttribute('style', 'display:none;');
        receivedElement.setAttribute('style', 'display:block;');

        console.log('Received Event: ' + id);
    }



};
