clc;
clear;
close all;

% Create a Constellation Diagram objects
constellationDiagram1 = comm.ConstellationDiagram('ShowGrid', true, 'Name', 'BPSK Constellation - Ideal');
constellationDiagram2 = comm.ConstellationDiagram('ShowGrid', true, 'Name', 'BPSK Constellation - Noisy');

% Anonymous functions used to modulate the input signal with given modulation scheme  
h_bpsk = @(input) pskmod(input, 2, 0, 'inputtype', 'bit');  % BPSK
h_qpsk = @(input) pskmod(input, 4, pi/4, 'inputtype', 'bit');  % QPSK
h_16qam = @(input) qammod(input, 16, 'inputtype', 'bit');  % 16-QAM
h_64qam = @(input) qammod(input, 64, 'inputtype', 'bit');  % 64-QAM
h_256qam = @(input) qammod(input, 256, 'inputtype', 'bit');  % 256-QAM

% Anonymous functions used to demodulate the output signal with given modulation scheme  
g_bpsk = @(input) pskdemod(input, 2, 0, 'outputtype', 'bit');  % BPSK
g_qpsk = @(input) pskdemod(input, 4, pi/4, 'outputtype', 'bit');  % QPSK
g_16qam = @(input) qamdemod(input, 16, 'outputtype', 'bit');  % 16-QAM
g_64qam = @(input) qamdemod(input, 64, 'outputtype', 'bit');  % 64-QAM
g_256qam = @(input) qamdemod(input, 256, 'outputtype', 'bit');  % 256-QAM

%%%%%%%% TRANSMITTER   

% Prepare image for transmission by converting it into a binary sequence
in=imread('leaf.png');  
N=numel(in);
in2=reshape(in,N,1);
bin=de2bi(in2,'left-msb');
input=reshape(bin',numel(bin),1);
len=length(input);

% Padding with zeros to make it compatible with the modulation schemes 
z=len;
while(rem(z,2) || rem(z,4)|| rem(z,6))
    z=z+1;
    input(z,1)=0;
end

% Modulate the input signal
y_bpsk = h_bpsk(input);
y_qpsk = h_qpsk(input);
y_16qam = h_16qam(input);
y_64qam = h_64qam(input);
y_256qam = h_256qam(input);
% Plot the constellation before transmission (Ideal Constellation)
% constellationDiagram1(y_16qam);  % Ideal constellation without noise
% imshow

%%%%%%%%%%%%%% CHANNEL 

% Frequency-Domain Signals (modulated symbols) >> Time-Domain using IFFT
ifft_out_bpsk=ifft(y_bpsk);
ifft_out_qpsk=ifft(y_qpsk);   
ifft_out_16qam=ifft(y_16qam);
ifft_out_64qam=ifft(y_64qam);
ifft_out_256qam=ifft(y_256qam);

% Add AWGN to Signals
SNR=15;          % SNR in dB
tx_bpsk = awgn(ifft_out_bpsk,SNR,'measured');
tx_qpsk = awgn(ifft_out_qpsk,SNR,'measured');
tx_16qam = awgn(ifft_out_16qam,SNR,'measured');
tx_64qam = awgn(ifft_out_64qam,SNR,'measured');
tx_256qam = awgn(ifft_out_256qam,SNR,'measured');

%%%%%%%%%%%%    RECEIVER

% Received signal is processed by applying the FFT to convert back to frequency domain 
k_bpsk=fft(tx_bpsk);
k_qpsk=fft(tx_qpsk);
k_16qam=fft(tx_16qam);
k_64qam=fft(tx_64qam);
k_256qam=fft(tx_256qam);

constellationDiagram2(k_256qam);  % Noisy constellation

% Received singal is demodulated
l_bpsk = pskdemod(k_bpsk, 2, 0, 'outputtype', 'bit'); 
l_qpsk = pskdemod(k_qpsk, 4, pi/4, 'outputtype', 'bit');
l_16qam = qamdemod(k_16qam, 16, 'outputtype', 'bit'); 
l_64qam = qamdemod(k_64qam, 64, 'outputtype', 'bit');
l_256qam = qamdemod(k_256qam, 256, 'outputtype', 'bit');

output_bpsk=uint8(l_bpsk);
output_qpsk=uint8(l_qpsk);
output_16qam=uint8(l_16qam);
output_64qam=uint8(l_64qam);
output_256qam=uint8(l_256qam);

output_bpsk=output_bpsk(1:len);
output_qpsk=output_qpsk(1:len);
output_16qam=output_16qam(1:len);
output_64qam=output_64qam(1:len);
output_256qam=output_256qam(1:len);

b_bpsk = reshape(output_bpsk, 8, N)';  % Reshape BPSK output into 8-bit blocks
b1=reshape(output_qpsk,8,N)';
b2=reshape(output_16qam,8,N)';
b3=reshape(output_64qam,8,N)';
b4=reshape(output_256qam,8,N);

dec_bpsk = bi2de(b_bpsk,'left-msb');
dec_qpsk = bi2de(b1,'left-msb');
dec_16qam = bi2de(b2,'left-msb');
dec_64qam = bi2de(b3,'left-msb');
dec_256qam = bi2de(b4,'left-msb');

% Compute the bit error rate
BER_bpsk = biterr(input, l_bpsk) / len;
BER_qpsk = biterr(input, l_qpsk) / len;
BER_16qam = biterr(input, l_16qam) / len;
BER_64qam = biterr(input, l_64qam) / len;
BER_256qam = biterr(input, l_256qam) / len;

% Display the BER for each modulation scheme
disp(BER_bpsk);
disp(BER_qpsk);
disp(BER_16qam);
disp(BER_64qam);
disp(BER_256qam);

%%%%%%%%% RECIEVED IMAGE DATA  

im_bpsk = reshape(dec_bpsk(1:N), size(in,1), size(in,2), size(in,3));
im_qpsk = reshape(dec_qpsk(1:N),size(in,1),size(in,2),size(in,3));
im_16qam = reshape(dec_16qam(1:N),size(in,1),size(in,2),size(in,3));
im_64qam = reshape(dec_64qam(1:N),size(in,1),size(in,2),size(in,3));
im_256qam = reshape(dec_64qam(1:N),size(in,1),size(in,2),size(in,3));

figure;
subplot(1,5,1);
imshow(im_bpsk);
title('BPSK');
xlabel(sprintf("BER: %.2e", BER_bpsk));

subplot(1,5,2);
imshow(im_qpsk);
title('QPSK');
xlabel(sprintf("BER: %.2e", BER_qpsk));

subplot(1,5,3);
imshow(im_16qam);
title('16-QAM');
xlabel(sprintf("BER: %.2e", BER_16qam));

subplot(1,5,4);
imshow(im_64qam);
title('64-QAM');
xlabel(sprintf("BER: %.2e", BER_64qam));

subplot(1,5,5);
imshow(im_256qam);
title('256-QAM');
xlabel(sprintf("BER: %.2e", BER_256qam));

sgtitle('Received Images');
set(gcf, 'Position', [100, 100, 2400, 600]); % Adjust figure size to fit 4 images