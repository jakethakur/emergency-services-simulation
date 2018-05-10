simulationLength = 12000; % length of simulation in "minutes"

% set position of hospital (where ambulance will return to)
hospitalPositionX = 0;
hospitalPositionY = 0;

Scale = 100; % size of area calls can come in from (multiplied by 2 by the program for positive and negative)
Prob = 0.1; % probability (out of 1) of an incoming call every hour

programRuns = 1; % number of times to run simulation (data from simulation will be saved into local folder and data.txt)

% Don't change any of the below code

% save information to local file called "data.txt"
fileID = fopen('data.txt','a');
fprintf(fileID,'---\n');
fclose(fileID);

for currentRun = 1 : programRuns % for loop to repeat simulation

    % Dist = zeros();
    % Dist2 = zeros();

    % x and y positions of random walk ambulance
    X = zeros (simulationLength, 1);
    Y = zeros (simulationLength, 1);

    Dist_Random = zeros(); % distance of random ambulance movement
    Dist_Nonrandom = zeros(); % distance of non-random ambulance movement

    X(1, 1) = hospitalPositionX; % array of x values (for random ambulance)
    Y(1, 1) = hospitalPositionY; % array of y values (for non-random ambulance)

    Xvalue = hospitalPositionX; % current x value (starting position)
    Yvalue = hospitalPositionY; % current y value (")

    callNumber = 1; % current call being dealt with



    for Timer = 2 : length(X) % for loop to repeat for each simulation minute

        random = rand; % generate random number
        random = floor(5 * random); % generate a random number between 0 and 4 to decide direction of random walk (or 0 for no random walk)

        % expect no movement (will be overwritten if there is)
        X(Timer, 1) = X(Timer - 1, 1);
        Y(Timer, 1) = Y(Timer - 1, 1);

        % random walk

        if random == 1 % move right
            if Xvalue > Scale % check the ambulance is not out of bounds
                X(Timer, 1) = X(Timer - 1, 1);
            else % move
                Xvalue = Xvalue + 1;
                X(Timer, 1) = Xvalue; % push current x value to array of x values
            end

        elseif random == 2 % move left
            if Xvalue < -Scale
                X(Timer, 1) = X(Timer - 1, 1);
            else
                Xvalue = Xvalue - 1;
                X(Timer, 1) = Xvalue;
            end

        elseif random == 3 % move up
            if Yvalue > Scale
                Y(Timer, 1) = Y(Timer - 1, 1);
            else
                Yvalue = Yvalue + 1;
                Y(Timer, 1) = Yvalue;
            end

        elseif random == 4 % move down
            if Yvalue < -Scale
                Y(Timer, 1) = Y(Timer - 1, 1);
            else
                Yvalue = Yvalue - 1;
                Y(Timer, 1) = Yvalue;
            end
        end

        if mod(Timer,60) == 1 % check if a new hour has elapsed
            r = binornd(1, Prob); % binomial distribution to check if a call has been received (1 = number of trials)
            if r > rand % ???
                % random call position within scale
                position (1, 1) = (rand - 0.5) * 2 * Scale; % random x position within scale
                position (1, 2) = (rand - 0.5) * 2 * Scale; % random y position within scale
                % ambulance moves instantly to call position
                X(Timer, 1) = position (1, 1); 
                Y(Timer, 1) = position (1, 2);
                % find distance that both ambulance types have moved to reach this call
                Dist_Random(callNumber, 1) = sqrt((position(1, 1) - X(Timer - 1, 1)) .^ 2 + (position(1, 2) - Y(Timer - 1, 1)) .^ 2);
                Dist_Nonrandom(callNumber, 1) = sqrt((position(1, 1) - 0) .^ 2 + (position(1, 2) - 0) .^ 2);

                callNumber = callNumber + 1;

                % return ambulance to hospital
                Timer = Timer + 1;
                Xvalue = hospitalPositionX;
                Yvalue = hospitalPositionY;
                X(Timer, 1) = Xvalue;
                Y(Timer, 1) = Yvalue;
            end
        end
    end

    % plot graphs

    % comet plot (visulisation of random ambulance moving) (figure1)
    ax = axes;
    set(ax,'xlim',[-Scale Scale],'ylim',[-Scale Scale]); % set axes
    hold (ax);
    comet (ax, X, Y);
    position = zeros (1, 2);

    % close all figures
    close all

    % random and nonrandom distances plotted against each other (figure2)
    figure;
    plot(Dist_Random(:, 1));
    hold on;
    plot(Dist_Nonrandom(:, 1));
    legend('random distance', 'nonrandom distance');

    % save figure2 to local file
    % warning: will overwrite image files with the same name - move the files after each simulation run!
    fileName = sprintf('image_%f.png',round(currentRun));
    saveas(gcf, fileName);

    % close all figures
    close all

    % print information to console
    fprintf('random distance: %f.\n',mean(Dist_Random));
    fprintf('nonrandom distance: %f.\n',mean(Dist_Nonrandom));

    % save information to local file called "data.txt"
    fileID = fopen('data.txt','a');
    fprintf(fileID,'simulation number %f.\n',round(currentRun));
    fprintf(fileID,'random distance: %f.\n',mean(Dist_Random));
    fprintf(fileID,'nonrandom distance: %f.\n',mean(Dist_Nonrandom));
    fclose(fileID);

    %mean(Dist_Random);
    %mean(Dist_Nonrandom);
end