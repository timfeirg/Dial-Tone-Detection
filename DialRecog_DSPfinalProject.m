% DSP course final project. Liu Yifu, San yat-sen university.
% this is the matlab .m file that calls the noise reduction function
% (noiseReduction.m) and dial recognition function (dialRecognition.m) to
% recognize any dialing sound from a .wav file and display the number.
% NOTE THAT:
% this program is designed for audio files that only contain the most
% common phone dialing sound

%% import data
clear all;clc;close all;
[hard,fs]=audioread('C:\Users\feirg\Google Drive\DSP projects\hard environment.mp3');
% sound(hard,fs)
%% frequency domain overview
% hardSnippet=hard(2.918e5:3.198e5);
figure(1)
subplot(211)
plot(hard)
title('{\bf Unprocessed data}')
subplot(212)
plot_fftshift(hard,fs);
%% noise reduction
% the sound of phone dial are basically a series of Dual-tone
% Multi-Frequency signals, the way i reduce the noise of these signals are
% basically attenuating all frequencies except those that compose DTMF
% signals.

% generating filter
Fs = 44100;  % Sampling Frequency

Fstop = 400;         % Stopband Frequency
Fpass = 650;         % Passband Frequency
Astop = 80;          % Stopband Attenuation (dB)
Apass = 1;           % Passband Ripple (dB)
match = 'stopband';  % Band to match exactly

% Construct an FDESIGN object and call its BUTTER method.
h  = fdesign.highpass(Fstop, Fpass, Astop, Apass, Fs);
Hd = design(h, 'butter', 'MatchExactly', match);
% finish generating filter

hardSilenced=filter(Hd,hard);
figure(2)
subplot(211)
plot(hardSilenced)
title('{\bf After high-pass filtering}')
subplot(212)
plot_fft(hardSilenced,fs);
title('')
% sound(hard,fs)
%% dialing tone recognition
% [peaks,peaks_indice]=findpeaks(hard_fft);
% plot(peaks_indice,peaks);