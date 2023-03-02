close all
clc

y_mono = ones(2880001,6);

[y, Fs] = audioread("Cory Wong -- 'Assassin' [The Paisley Park Session].mp3", [2880000,5760000]);
y_mono(:,1) = y(:,1);
[y, Fs] = audioread("Cory Wong -- 'Concrete' (feat. Mark Lettieri).mp3", [2880000,5760000]);
y_mono(:,3) = y(:,1);
[y, Fs] = audioread("Cory Wong -- 'Power Station'.mp3", [2880000,5760000]);
y_mono(:,5) = y(:,1);
[y, Fs] = audioread("HAKEN - Canary Yellow (OFFICIAL VIDEO).mp3", [2880000,5760000]);
y_mono(:,2) = y(:,1);
[y, Fs] = audioread("HAKEN - Atlas Stone (ALBUM TRACK).mp3", [2880000,5760000]);
y_mono(:,4) = y(:,1);
[y, Fs] = audioread("HAKEN - The Endless Knot (Lyric Video).mp3", [2880000,5760000]);
y_mono(:,6) = y(:,1);

L = length(y);
x_freq = Fs.*(0:L/2-1)/L;
x_freq_trim = x_freq(1:60000);

for i = 1:40

    num = i*25;
    buckets(i,:) = num;

end

for n = 1:6

    FFT_mirrored(:,n) = abs(fft(y_mono(:,n),L));
    var = FFT_mirrored(:,n);
    FFT = var(1:L/2);
    FFT_trim(:,n) = FFT(1:60000);
    
    figure(1)
    subplot(3,2,n)
    plot(x_freq_trim, FFT_trim(:,n))
    findpeaks(FFT_trim(:,n),x_freq_trim,'MinPeakProminence',8000,'MinPeakDistance',1)
    [peaks, x] = findpeaks(FFT_trim(:,n),x_freq_trim,'MinPeakProminence',8000,'MinPeakDistance',1);
    
    figure(2)
    subplot(3,2,n)
    h(n,:) = histogram(x,buckets);

end


