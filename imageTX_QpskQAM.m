clc;
close all;

%% Modulators Objects
h_qpsk = @(input) pskmod(input, 4, pi/4, 'inputtype', 'bit');  % QPSK
h_16qam = @(input) qammod(input, 16, 'inputtype', 'bit');  % 16-QAM
h_64qam = @(input) qammod(input, 64, 'inputtype', 'bit');  % 64-QAM

%%% Demodulator Objects
g_qpsk = @(input) pskdemod(input, 4, pi/4, 'outputtype', 'bit');  % QPSK
g_16qam = @(input) qamdemod(input, 16, 'outputtype', 'bit');  % 16-QAM
g_64qam = @(input) qamdemod(input, 64, 'outputtype', 'bit');  % 64-QAM

%%%%% TRANSMITTER   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
in=imread('campus.jpg');    % image to be transmitted and matlab code should be in same directory
N=numel(in);
in2=reshape(in,N,1);
bin=de2bi(in2,'left-msb');
input=reshape(bin',numel(bin),1);
len=length(input);

%%%%% padding zeroes to input %%%
z=len;
while(rem(z,2) || rem(z,4)|| rem(z,6))
    z=z+1;
    input(z,1)=0;
end

y_qpsk = h_qpsk(input);
y_16qam = h_16qam(input);
y_64qam = h_64qam(input);


ifft_out_qpsk=ifft(y_qpsk);
ifft_out_16qam=ifft(y_16qam);
ifft_out_64qam=ifft(y_64qam);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

SNR=10;          % SNR in dB
tx_qpsk=awgn(ifft_out_qpsk,SNR,'measured');
tx_16qam=awgn(ifft_out_16qam,SNR,'measured');
tx_64qam=awgn(ifft_out_64qam,SNR,'measured');

%%%%    RECEIVER  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
k_qpsk=fft(tx_qpsk);
k_16qam=fft(tx_16qam);
k_64qam=fft(tx_64qam);

l_qpsk = pskdemod(k_qpsk, 4, pi/4, 'outputtype', 'bit');
l_16qam = qamdemod(k_16qam, 16, 'outputtype', 'bit'); 
l_64qam = qamdemod(k_64qam, 64, 'outputtype', 'bit');

output_qpsk=uint8(l_qpsk);
output_16qam=uint8(l_16qam);
output_64qam=uint8(l_64qam);

output_qpsk=output_qpsk(1:len);
output_16qam=output_16qam(1:len);
output_64qam=output_64qam(1:len);

b1=reshape(output_qpsk,8,N)';
b2=reshape(output_16qam,8,N)';
b3=reshape(output_64qam,8,N)';

dec_qpsk=bi2de(b1,'left-msb');
dec_16qam=bi2de(b2,'left-msb');
dec_64qam=bi2de(b3,'left-msb');

%%% BER %%%%%%
BER_qpsk = biterr(input, l_qpsk) / len;
BER_16qam = biterr(input, l_16qam) / len;
BER_64qam = biterr(input, l_64qam) / len;

disp(BER_qpsk);
disp(BER_16qam);
disp(BER_64qam);


%%%% RECIEVED IMAGE DATA  %%%%%%%
im_qpsk=reshape(dec_qpsk(1:N),size(in,1),size(in,2),size(in,3));
im_16qam=reshape(dec_16qam(1:N),size(in,1),size(in,2),size(in,3));
im_64qam=reshape(dec_64qam(1:N),size(in,1),size(in,2),size(in,3));
figure;
subplot(131);
imshow(im_qpsk);title('QPSK');
xlabel("BER: "+BER_qpsk);

subplot(132);
imshow(im_16qam);title('16-QAM');
xlabel("BER: "+BER_16qam);
subplot(133);
imshow(im_64qam);title('64-QAM');
xlabel("BER: "+BER_64qam);
sgtitle('Received Images'); % Super title for the whole figure



