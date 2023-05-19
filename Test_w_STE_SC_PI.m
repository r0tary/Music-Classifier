close all
clear all
clc

%Link to download music archive https://drive.proton.me/urls/KZ3ZVQNNDM#e7NL6TU2FEPE

%Variables are named throughout so they are more sorted on the workspace sidebar

%folder location, creating  audio datastore
folder_blues = fullfile("Music/archive/Data/genres_original/blues");
AD_blues = audioDatastore(folder_blues,'FileExtension','.wav');

folder_rock = fullfile("Music/archive/Data/genres_original/rock");
AD_rock = audioDatastore(folder_rock,'FileExtensions','.wav');

folder_hiphop = fullfile("Music/archive/Data/genres_original/hiphop");
AD_hiphop = audioDatastore(folder_hiphop,'FileExtensions','.wav');

%%
% Ploting short-time enrgy of three genres - rock, blues and hiphop
[y,Fs] = audioread("Music\archive\Data\genres_original\blues\blues.00025.wav");
    
aFE = audioFeatureExtractor( ...
    SampleRate=Fs, ...
    Window = hamming(round(0.03*Fs),"periodic"), ...
    OverlapLength = round(0.02*Fs), ...
    mfcc = false, ...
    mfccDelta = false, ...
    mfccDeltaDelta = false, ...
    pitch = true, ...
    spectralCentroid = true, ...
    zerocrossrate = false, ...
    shortTimeEnergy = true);

features = extract(aFE,y);
idx = info(aFE)
%t = linspace(0,size(y,1)/Fs,size(features,1));

figure(1)
subplot(2,2,1)
hold on
plot(features(:,idx.shortTimeEnergy))
title("Short-Time Energy - Blues")
xlabel("Time")

figure(2)
subplot(2,2,1)
hold on
plot(features(:,idx.spectralCentroid))
title("Spectral Centroid - Blues")
xlabel("Time")
ylabel("Centroid (Hz)")

figure(3)
subplot(2,2,1)
hold on
plot(features(:,idx.pitch))
xlim([0 300])
title("Pitch - Blues")
xlabel("Time")

[y,Fs] = audioread("Music\archive\Data\genres_original\rock\rock.00025.wav");
features = extract(aFE,y);
idx = info(aFE);

figure(1)
subplot(2,2,2)
hold on
plot(features(:,idx.shortTimeEnergy))
title("Short-Time Energy - Rock")
xlabel("Time")


figure(2)
subplot(2,2,2)
hold on
plot(features(:,idx.spectralCentroid))
title("Spectral Centroid - Rock")
xlabel("Time")
ylabel("Centroid (Hz)")

figure(3)
subplot(2,2,2)
hold on
plot(features(:,idx.pitch))
xlim([0 300])
title("Pitch - Rock")
xlabel("Time")


[y,Fs] = audioread("Music\archive\Data\genres_original\hiphop\hiphop.00025.wav");
features = extract(aFE,y);
idx = info(aFE);

figure(1)
subplot(2,2,3)
hold on
plot(features(:,idx.shortTimeEnergy))
title("Short-Time Energy - HipHop")
xlabel("Time")

figure(2)
subplot(2,2,3)
hold on
plot(features(:,idx.spectralCentroid))
title("Spectral Centroid - HipHop")
xlabel("Time")
ylabel("Centroid (Hz)")

figure(3)
subplot(2,2,3)
hold on
plot(features(:,idx.pitch))
xlim([0 300])
title("Pitch - HipHop")
xlabel("Time")

%%
%Reading audio files
for i = 1:100
    [audio_Blues(:,i), Fs] = audioread(string(AD_blues.Files(i,1)),[1,660000]);
    fprintf('Blues - Audio file Nr. %d\n',size(audio_Blues,2))
end

for i = 1:100
    [audio_rock(:,i), Fs] = audioread(string(AD_rock.Files(i,1)),[1,660000]);
    fprintf('Metal - Audio file Nr. %d\n',size(audio_rock,2))
end

for i = 1:100
    [audio_hiphop(:,i), Fs] = audioread(string(AD_hiphop.Files(i,1)),[1,660000]);
    fprintf('Hip Hop - Audio file Nr. %d\n',size(audio_hiphop,2))
end

audio_all = [audio_Blues audio_rock audio_hiphop];%Combining into a single array
song_count = length(audio_all(1,:));
L = length(audio_all(:,1));         %length of samples 

x_freq = Fs.*(0:L/2-1)/L;           % Calculate frequencies for X axis
x_freq_trim = x_freq(1:60000);      % Trim frequencies to audible spectrum (1000Hz)

%clearing arrays that are not needed, saves a bit of RAM
clear audio_Blues audio_rock audio_hiphop

%%
% Calculating needed parameters for the model
disp('Getting peak number, span and average...')
for n = 1:song_count
    fprintf('Audio file: %d\n',n)

    FFT_mirrored(:,n) = abs(fft(audio_all(:,n),L));
    var = FFT_mirrored(:,n);
    FFT = var(1:L/2);
    FFT_trim(:,n) = FFT(1:60000);
   
    %Find number of peaks
    [peaks, x] = findpeaks(FFT_trim(:,n),x_freq_trim,'MinPeakProminence',1000,'MinPeakDistance',1);
    data_peak_num(:,n) = length(peaks);

    [prom_peaks, x] = findpeaks(FFT_trim(:,n),x_freq_trim,'MinPeakProminence',1350,'MinPeakDistance',1);
    data_prom_peak_num(:,n) = length(prom_peaks);
    
    %Max frequency where a peak occurs and average value of signal
    data_span(:,n) = max(x);
    data_avg(:,n) = mean(FFT_trim(:,n));

    %Extracting features using audio feature extractor
    features = extract(aFE,audio_all(:,n));
    
    %Getting the Prom peak number, average value and max value of
    %Short-Time Energy
    [ste_prom_peaks, x] = findpeaks(features(:,3),'MinPeakProminence',35,'MinPeakDistance',1);
    data_STE_peak_num(:,n) = length(ste_prom_peaks);
    data_STE_avg(:,n) = mean(features(:,3));
    data_STE_max(:,n) = max(features(:,3));

    %Extracting avg Pitch
    data_Pitch_avg(:,n) = mean(features(:,2));

    %Extracting average and peak number of spectral centroid
    [ce_prom_peaks, x] = findpeaks(features(:,1),'MinPeakProminence',1500,'MinPeakDistance',1);
    data_SC_peak_num(:,n) = length(ce_prom_peaks);
    data_SC_avg(:,n) = mean(features(:,1));

end
disp('Parameter/feature extraction = done')

%%
% Ploting data
figure(4)
subplot(2,2,1)
hold on
scatter(data_peak_num(1:84), data_span(1:84), 'red') %Blues
scatter(data_peak_num(85:168), data_span(85:168), 'blue') %Rock
scatter(data_peak_num(169:252), data_span(169:252), 'green') %HipHop
xlabel('Number of peaks')
ylabel('Maximum frequency (Hz)')
legend('Blues', 'Rock', 'HipHop')

subplot(2,2,2)
hold on
scatter(data_avg(1:84), data_peak_num(1:84), 'red') %Blues
scatter(data_avg(85:168), data_peak_num(85:168), 'blue') %Rock
scatter(data_avg(169:252), data_peak_num(169:252), 'green') %HipHop
xlabel('Average value of signal')
ylabel('Number of peaks')
legend('Blues', 'Rock', 'HipHop')

subplot(2,2,3)
hold on
scatter(data_avg(1:84), data_span(1:84), 'red') %Blues
scatter(data_avg(85:168), data_span(85:168), 'blue') %Rock
scatter(data_avg(169:252), data_span(169:252), 'green') %HipHop
xlabel('Average value of signal')
ylabel('Maximum frequency (Hz')
legend('Blues', 'Rock', 'HipHop')

subplot(2,2,4)
hold on
scatter(data_prom_peak_num(1:84), data_span(1:84), 'red') %Blues
scatter(data_prom_peak_num(85:168), data_span(85:168), 'blue') %Rock
scatter(data_prom_peak_num(169:252), data_span(169:252), 'green') %HipHop
xlabel('Number of prominant peaks')
ylabel('Maximum frequency (Hz)')
legend('Blues', 'Rock', 'HipHop')


figure(5)
%Ploting short time enrgy peaknumber vs max and average
subplot(2,2,1)
hold on
scatter(data_STE_peak_num(1:84), data_STE_max(1:84), 'red') %Blues
scatter(data_STE_peak_num(85:168), data_STE_max(85:168), 'blue') %Rock
scatter(data_STE_peak_num(169:252), data_STE_max(169:252), 'green') %HipHop
xlabel('Number of peaks')
ylabel('Maximum value')
legend('Blues', 'Rock', 'HipHop')

subplot(2,2,2)
hold on
scatter(data_STE_peak_num(1:84), data_STE_avg(1:84), 'red') %Blues
scatter(data_STE_peak_num(85:168), data_STE_avg(85:168), 'blue') %Rock
scatter(data_STE_peak_num(169:252), data_STE_avg(169:252), 'green') %HipHop
xlabel('Average of STE')
ylabel('Number of peaks')
legend('Blues', 'Rock', 'HipHop')

%Ploting spectral centroid peak number vs average
subplot(2,2,3)
hold on
scatter(data_SC_peak_num(1:84), data_SC_avg(1:84), 'red') %Blues
scatter(data_SC_peak_num(85:168), data_SC_avg(85:168), 'blue') %Rock
scatter(data_SC_peak_num(169:252), data_SC_avg(169:252), 'green') %HipHop
xlabel('Number of Spectral Centroid peaks')
ylabel('Average Spectral Centroid')
legend('Blues', 'Rock', 'HipHop')

%%
% Creating a array with classes coresponding to audio data
disp('Creating an array with coresponding classes');
for i = 1:100;
    class(i,:) = "Blues"; 
end

for i = 1:100;
    class(100+i,:) = "Rock"; 
end

for i = 1:100;
    class(200+i,:) = "HipHop"; 
end
disp('Array with classes = done')

%%
% Shuffling both arrays so they still match up when shuffled
disp('Shufling the data')

%Current used classification parameters:
        % short time energy - average value and max value
        % spectral centroid - average and peak number
        % pitch - average value

 data_all = transpose([ ...
    data_STE_max(1:song_count); data_STE_avg(1:song_count); ...
    data_SC_avg(1:song_count); data_SC_peak_num(1:song_count); ...
    data_Pitch_avg(1:song_count)]);

%clearing un-used arrays, save a bit of RAM space
    clear data_STE_max data_STE_avg data_STE_peak_num
    clear data_prom_peak_num data_avg data_span data_peak_num
    clear FFT FFT_trim FFT_mirrored
    clear data_SC_peak_num data_SC_avg data_Pitch_avg

%%
P = randperm(length(data_all));
Mdl_x = data_all(P,:);
Mdl_y = class(P);

% Spliting the data into train and test, will use when further testing will
% be done
    cv = cvpartition(size(Mdl_x,1),"HoldOut",0.20);
    idx = cv.test;
    Mdl_x_train = Mdl_x(cv.training,:);
    Mdl_y_train = Mdl_y(cv.training,:);
    Mdl_x_test = Mdl_x(cv.test,:);
    Mdl_y_test = Mdl_y(cv.test,:);

%%
disp('Training the model')
% Training the model
%Mdl = fitcknn(Mdl_x, Mdl_y,'NumNeighbors',2,'Standardize',1);
Mdl = fitcknn(Mdl_x_train, Mdl_y_train,'NumNeighbors',6,'Standardize',1);

CV_KNN = crossval(Mdl);
classError = kfoldLoss(CV_KNN)

prediction = ones(1,60);
prediction = string(prediction);

for k = 1:60
    prediction(k) = predict(Mdl, Mdl_x_test(k,:));
end

prediction = transpose(prediction);

for k = 1:60
    comp(k) = strcmp(Mdl_y_test(k,1),prediction(k,1));
end

acc = sum(comp)/60
