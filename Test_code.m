close all
clear all
clc

y_mono = ones(2880001,20); % From stereo audio to mono


% Read the  first and second minute of every song. Numbering scheme:
% 1,3,5,7,9 - Jazz, first minute
% 2,4,6,8,10 - Rock, first minute
% 11,13,15,17,19 - Jazz, second minute
% 12,14,16,18,20 - Rock, second minute
[y, Fs] = audioread("Cory Wong -- 'Assassin' [The Paisley Park Session].mp3", [2880000,5760000]);
y_mono(:,1) = y(:,1);
[y, Fs] = audioread("Cory Wong -- 'Concrete' (feat. Mark Lettieri).mp3", [2880000,5760000]);
y_mono(:,3) = y(:,1);
[y, Fs] = audioread("Cory Wong -- 'Power Station'.mp3", [2880000,5760000]);
y_mono(:,5) = y(:,1);
[y, Fs] = audioread("Cory Wong -- 'News To Me' (feat. Nate Smith).mp3", [2880000,5760000]);
y_mono(:,7) = y(:,1);
[y, Fs] = audioread("Starfire.mp3", [2880000,5760000]);
y_mono(:,9) = y(:,1);
[y, Fs] = audioread("HAKEN - Canary Yellow (OFFICIAL VIDEO).mp3", [2880000,5760000]);
y_mono(:,2) = y(:,1);
[y, Fs] = audioread("HAKEN - Atlas Stone (ALBUM TRACK).mp3", [2880000,5760000]);
y_mono(:,4) = y(:,1);
[y, Fs] = audioread("HAKEN - The Endless Knot (Lyric Video).mp3", [2880000,5760000]);
y_mono(:,6) = y(:,1);
[y, Fs] = audioread("HAKEN - 1985 (Album Track).mp3", [2880000,5760000]);
y_mono(:,8) = y(:,1);
[y, Fs] = audioread("HAKEN - A Cell Divides (OFFICIAL VIDEO).mp3", [2880000,5760000]);
y_mono(:,10) = y(:,1);
[y, Fs] = audioread("Cory Wong -- 'Assassin' [The Paisley Park Session].mp3", [5760000, 8640000]);
y_mono(:,11) = y(:,1);
[y, Fs] = audioread("Cory Wong -- 'Concrete' (feat. Mark Lettieri).mp3", [5760000, 8640000]);
y_mono(:,13) = y(:,1);
[y, Fs] = audioread("Cory Wong -- 'Power Station'.mp3", [5760000, 8640000]);
y_mono(:,15) = y(:,1);
[y, Fs] = audioread("Cory Wong -- 'News To Me' (feat. Nate Smith).mp3", [5760000, 8640000]);
y_mono(:,17) = y(:,1);
[y, Fs] = audioread("Starfire.mp3", [5760000, 8640000]);
y_mono(:,19) = y(:,1);
[y, Fs] = audioread("HAKEN - Canary Yellow (OFFICIAL VIDEO).mp3", [5760000, 8640000]);
y_mono(:,12) = y(:,1);
[y, Fs] = audioread("HAKEN - Atlas Stone (ALBUM TRACK).mp3", [5760000, 8640000]);
y_mono(:,14) = y(:,1);
[y, Fs] = audioread("HAKEN - The Endless Knot (Lyric Video).mp3", [5760000, 8640000]);
y_mono(:,16) = y(:,1);
[y, Fs] = audioread("HAKEN - 1985 (Album Track).mp3", [5760000, 8640000]);
y_mono(:,18) = y(:,1);
[y, Fs] = audioread("HAKEN - A Cell Divides (OFFICIAL VIDEO).mp3", [5760000, 8640000]);
y_mono(:,20) = y(:,1);

% Additional test songs

[y, Fs] = audioread("For Whom The Bell Tolls (Remastered).mp3", [5760000, 8640000]);
y_mono(:,21) = y(:,1);



L = length(y); % define length of samples 
x_freq = Fs.*(0:L/2-1)/L; % Calculate frequencies for X axis
x_freq_trim = x_freq(1:60000); % Trim frequencies to audible spectrum (1000Hz)

% define bucket boundaries for histograms (nothing to do with actual DSP, could be commented out if you dont want to view histograms)

for i = 1:40

    num = i*25;
    buckets(i,:) = num;

end

% Make FFT of each song snippet (same procedure as cake exercise)

for n = 1:21

    FFT_mirrored(:,n) = abs(fft(y_mono(:,n),L));
    var = FFT_mirrored(:,n);
    FFT = var(1:L/2);
    FFT_trim(:,n) = FFT(1:60000);
    
    figure(1)
    subplot(11,2,n)
    plot(x_freq_trim, FFT_trim(:,n))

    % find number of peaks of FFT (one of the parameters with which we classify the songs)
    
    [peaks, x] = findpeaks(FFT_trim(:,n),x_freq_trim,'MinPeakProminence',8000,'MinPeakDistance',1);
   
    peak_num(:,n) = length(peaks);

    [prom_peaks, x] = findpeaks(FFT_trim(:,n),x_freq_trim,'MinPeakProminence',12000,'MinPeakDistance',1);
   
    prom_peak_num(:,n) = length(prom_peaks);


    % figure(2)
    % subplot(10,2,n)
    % h(n,:) = histogram(x,buckets);

   % find max frequency where a peak occurs and average value of signal,
   % the other two values we will use to classify songs
    
    span(:,n) = max(x);
    avg(:,n) = mean(FFT_trim(:,n));

end


%%

figure(3)

subplot(2,2,1)
hold on
scatter(peak_num([1,3,5,7,9,11,13,15,17,19]), span([1,3,5,7,9,11,13,15,17,19]), 'red')
scatter(peak_num([2,4,6,8,10,12,14,16,18,20]), span([2,4,6,8,10,12,14,16,18,20]), 'blue')
scatter(peak_num(21), span(21), 'green')

subplot(2,2,2)
hold on
scatter(avg([1,3,5,7,9,11,13,15,17,19]), peak_num([1,3,5,7,9,11,13,15,17,19]), 'red')
scatter(avg([2,4,6,8,10,12,14,16,18,20]), peak_num([2,4,6,8,10,12,14,16,18,20]), 'blue')
scatter(avg(21), peak_num(21), 'green')

subplot(2,2,3)
hold on
scatter(avg([1,3,5,7,9,11,13,15,17,19]), span([1,3,5,7,9,11,13,15,17,19]), 'red')
scatter(avg([2,4,6,8,10,12,14,16,18,20]), span([2,4,6,8,10,12,14,16,18,20]), 'blue')
scatter(avg(21), span(21), 'green')

subplot(2,2,4)
hold on
scatter(prom_peak_num([1,3,5,7,9,11,13,15,17,19]), span([1,3,5,7,9,11,13,15,17,19]), 'red')
scatter(prom_peak_num([2,4,6,8,10,12,14,16,18,20]), span([2,4,6,8,10,12,14,16,18,20]), 'blue')
scatter(prom_peak_num(21), span(21), 'green')


% Define the classes of each song (we will use 8 songs to train and 13 to test)

class = ['jazz'; 'rock'; 'jazz'; 'rock'; 'jazz'; 'rock'; 'jazz'; 'rock';'jazz'; 'rock'; 'jazz'; 'rock'];

% Create input array of data

data = transpose([peak_num(1:12);avg(1:12);span(1:12);prom_peak_num(1:12)]);

% make KNN model

Mdl = fitcknn(data,class,'NumNeighbors',3,'Standardize',1);

prediction = ones(1,21);

prediction = string(prediction);

% predict the other 12 songs

for k = 13:21

prediction(k) = predict(Mdl, [peak_num(k) avg(k) span(k) prom_peak_num(k)]);

end



