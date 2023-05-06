close all
clear all

y_mono = ones(2880001,20); % From stereo audio to mono

[y, Fs] = audioread("Music/Cory Wong -- 'Assassin' [The Paisley Park Session].mp3", [2880000,5760000]);
y_mono(:,1) = y(:,1);

[y, Fs] = audioread("Music/HAKEN - Canary Yellow (OFFICIAL VIDEO).mp3", [2880000,5760000]);
y_mono(:,2) = y(:,1);

aFE = audioFeatureExtractor( ...
    SampleRate=Fs, ...
    Window = hamming(round(0.03*Fs),"periodic"), ...
    OverlapLength = round(0.02*Fs), ...
    mfcc = true, ...
    mfccDelta = false, ...
    mfccDeltaDelta = false, ...
    pitch = true, ...
    spectralCentroid = true, ...
    zerocrossrate = true, ...
    shortTimeEnergy = true);

for n = 0:1

    features = extract(aFE,y_mono(:,n + 1));
    
    idx = info(aFE)
    
    t = linspace(0,size(y_mono(:,n + 1),1)/Fs,size(features,1));
    
    subplot(5,2,1 + n)
    plot(t,features(:,idx.pitch))
    title("Pitch")
    xlabel("Time (s)")
    ylabel("Frequency (Hz)")
    
    subplot(5,2,3 + n)
    plot(t,features(:,idx.zerocrossrate))
    title("Zero-Crossing Rate")
    xlabel("Time (s)")
    
    subplot(5,2,5 + n)
    plot(t,features(:,idx.shortTimeEnergy))
    title("Short-Time Energy")
    xlabel("Time (s)")
    
    subplot(5,2,7 + n)
    plot(t,features(:,idx.spectralCentroid))
    title("Spectral Centroid")
    xlabel("Time(s)")
    ylabel("Centroid(Hz)")
    
    subplot(5,2,9 + n)
    plot(t,features(:,idx.mfcc))
    title("Mel-frequency cepstral coefficients")
    xlabel("Time(s)")
    ylabel("MFCC")

end