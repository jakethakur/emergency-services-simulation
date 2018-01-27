var canvas = document.getElementById("canvas");
    var processing = new Processing(canvas, function(processing) {
        processing.size(400, 400);
        processing.background(0xFFF);

        var mouseIsPressed = false;
        processing.mousePressed = function () { mouseIsPressed = true; };
        processing.mouseReleased = function () { mouseIsPressed = false; };

        var keyIsPressed = false;
        processing.keyPressed = function () { keyIsPressed = true; };
        processing.keyReleased = function () { keyIsPressed = false; };

        function getImage(s) {
            var url = "https://www.kasandbox.org/programming-images/" + s + ".png";
            processing.externals.sketch.imageCache.add(url);
            return processing.loadImage(url);
        }

        // use degrees rather than radians in rotate function
        var rotateFn = processing.rotate;
        processing.rotate = function (angle) {
            rotateFn(processing.radians(angle));
        };

        with (processing) {


            //processing import from https://stackoverflow.com/a/25341598

			//bug - sometimes misses a tick

			var callgen = 1; //how the calls are to be generated
			//1 = random via poisson process
			//2 = regular intervals the same as response time
			//3 = regular intervals half of response time
			//you may use your own array of data here also, by setting callgen to 4
			var generatenew = true; //whether new calls should be generated on restart

			var mean = 4; //mean calls per hour for if callgen is 1
			var responseTime = 0.5; //time taken to respond to a call
			var ambulances = 2; //number of ambulances avaliable
			var cases = 100; //number of calls (too many will go off the screen and will require altering of display)
			var ticklength = 0.05; //amount that a time tick lasts for (small values will cause more precision, but slower queue generation times)

			var display = { //edit the graph
				timedisplaystart: 0, //what index to start showing calls at
				timedisplayresolution: 30, //how much spacing between calls
				repeat: 600, //if the graph cuts off after a while, or runs for too long, change this
				xaxis: 0.75,
				yaxis: 25,
			};

			//don't change any of the below variables

			var times = [0]; //array of call times (in hours) - add your own times to this array if you want your own times insead (don't forget to change the callgen to 4)
			var waitTimes = [0]; //array of times that each caller had to wait in order to be dealt with (if it makes it more accurate to you, it might help to add the time taken for ambulance to reach there in the first place as well)
			var queueLength = [0]; //array of queuelengths

			var waitTimeAnalysis = {
				total: 0,
				average: 0,
			};

			var currentQueueLength = 0; //the current queue length
			var ambulancesOccupiedUntil = [1000000000]; //time the ambulances will be occupied until
			var ambulancesOccupied = [false]; //whether the ambulance is currently occupied
			var currentCall = 1; //array index of the next call the ambulance will deal with
			var currentIncomingCall = 1; //array index of the next expected incoming call

			for(var i = 0; i < ambulances; i++){
				ambulancesOccupied.push(false);
				ambulancesOccupiedUntil.push(1000000000);
			}

			fill(0, 0, 0);
			textSize(11);

			var time = 0; //time (used to calculate queue)

			var poisson = function(expectvalue){
				//credit: https://gist.github.com/yuanyan/997516
				var n = 0;
				var limit = Math.exp(-expectvalue);
				var x = Math.random();

				while(x > limit){
					n++;
					x *= Math.random();
				}

				return n;
			};

			//generate calls
			if(generatenew){
				for(var i = 0; i < cases; i++){
					if(callgen === 1){
						//times.push(times[times.length - 1] + Math.log(Math.random()) / mean); //BROKEN
						times.push(times[times.length - 1] + poisson((1/mean)*100)/100);
					}
					else if(callgen === 2){
						times.push(times[times.length - 1] + responseTime + ticklength);
					}
					else if(callgen === 3){
						times.push(times[times.length - 1] + responseTime / 2 + ticklength);
					}
					else{
						//user inputed their own data
					}
				}
			}

			var nextReturningambulance = function() {
				var minimumTime = 10000000000;
				for(var i = 0; i < ambulances; i++){
					if(!ambulancesOccupied[i]){
						minimumTime = 0;
						break;
					}
					if(ambulancesOccupiedUntil[i] < minimumTime){
						minimumTime = ambulancesOccupiedUntil[i];   
					}
				}
				return minimumTime;
			};

			var draw = function() {
				background(255, 255, 255);
				time += ticklength; //increase time
				text(time,351,10); //display time at top-right of screen
				//text(currentQueueLength,200,200);
				//text(times,88,192);
				
				//display call time data
				for(var i = 0; i < cases + 1; i++){ //call number
					text(i + display.timedisplaystart,5,times[i]*display.timedisplayresolution);
				}
				for(var i = 0; i < cases + 1; i++){ //call time
					text(times[i + display.timedisplaystart],25,times[i]*display.timedisplayresolution);
				}
				for(var i = 0; i < cases + 1; i++){ //wait times
					text(waitTimes[i + display.timedisplaystart],75,times[i]*display.timedisplayresolution);
				}
				text("Average waiting time: " + waitTimeAnalysis.average,240,40); //wait time average
				
				//calculate queue
				//to be updated...
				if(time >= times[currentIncomingCall]){ //check for a new call
					/*if(waitTimes.length !== 1){
						if((ambulanceOccupiedUntil - time) > 0){
						waitTimes.push((ambulanceOccupiedUntil - time) + (currentQueueLength * responseTime));
						waitTimeAnalysis.total += (ambulanceOccupiedUntil - time) + (currentQueueLength * responseTime);
						}
						else{
							waitTimes.push(currentQueueLength * responseTime);
							waitTimeAnalysis.total += currentQueueLength * responseTime;
						}
						waitTimeAnalysis.average = waitTimeAnalysis.total / waitTimes.length;
					}
					else{
						waitTimes.push(0);
					}*/
					currentQueueLength++;
					currentIncomingCall++;
				}
				
				for(var i = 0; i < ambulances; i++){
					if(ambulancesOccupied[i] && time >= ambulancesOccupiedUntil[i]){ //check if an ambulance is free
						ambulancesOccupied[i] = false;
					}
				}
				
				for(var i = 0; i < ambulances; i++){
					if(!ambulancesOccupied[i] && time >= times[currentCall]){ //check if ambulance can go out again
						ambulancesOccupied[i] = true;
						currentCall++;
						ambulancesOccupiedUntil[i] = time + responseTime;
						currentQueueLength--;
						break;
					}
				}
				
				queueLength.push(currentQueueLength); //push data about queue
				
				//draw graph
				for(var i = 0; i < display.repeat; i++){
					//point(i, 400 - queueLength[i] * 50);
					line(i*display.xaxis, 398 - queueLength[i] * display.yaxis, (i+1)*display.xaxis, 398 - queueLength[i+1] * display.yaxis);
				}
			};


        }
        if (typeof draw !== 'undefined') processing.draw = draw;
    });