clc;
close all;

% Clear all text file logs
fileID = fopen('logs/1024-QAM_BER.txt', 'w'); % Open file for writing
fclose(fileID); % Close the file
fileID = fopen('logs/512-QAM_BER.txt', 'w'); % Open file for writing
fclose(fileID); % Close the file
fileID = fopen('logs/256-QAM_BER.txt', 'w'); % Open file for writing
fclose(fileID); % Close the file
fileID = fopen('logs/64-QAM_BER.txt', 'w'); % Open file for writing
fclose(fileID); % Close the file
fileID = fopen('logs/16-QAM_BER.txt', 'w'); % Open file for writing
fclose(fileID); % Close the file
fileID = fopen('logs/QPSK_BER.txt', 'w'); % Open file for writing
fclose(fileID); % Close the file
fileID = fopen('logs/BPSK_BER.txt', 'w'); % Open file for writing
fclose(fileID); % Close the file
fileID = fopen('logs/MILL188-32-QAM_BER.txt', 'w'); % Open file for writing
fclose(fileID); % Close the file


SNR_list = -40:40;
for i = 1:length(SNR_list)

    % Anonymous functions used to modulate the input signal with given modulation scheme  
    h_bpsk = @(input) pskmod(input, 2, 0, 'inputtype', 'bit');  % BPSK
    h_qpsk = @(input) pskmod(input, 4, pi/4, 'inputtype', 'bit');  % QPSK
    h_16qam = @(input) qammod(input, 16, 'inputtype', 'bit');  % 16-QAM
    h_64qam = @(input) qammod(input, 64, 'inputtype', 'bit');  % 64-QAM
    h_256qam = @(input) qammod(input, 256, 'inputtype', 'bit');  % 256-QAM
    h_512qam = @(input) qammod(input, 512, 'inputtype', 'bit');  % 512-QAM
    h_1024qam = @(input) qammod(input, 1024, 'inputtype', 'bit');  % 1024-QAM
    h_mil188qam = @(input) mil188qammod(input,32,'inputtype','bit'); % Mil188-32-QAM

    % Anonymous functions used to demodulate the output signal with given modulation scheme  
    g_bpsk = @(input) pskdemod(input, 2, 0, 'outputtype', 'bit');  % BPSK
    g_qpsk = @(input) pskdemod(input, 4, pi/4, 'outputtype', 'bit');  % QPSK
    g_16qam = @(input) qamdemod(input, 16, 'outputtype', 'bit');  % 16-QAM
    g_64qam = @(input) qamdemod(input, 64, 'outputtype', 'bit');  % 64-QAM
    g_256qam = @(input) qamdemod(input, 256, 'outputtype', 'bit');  % 256-QAM
    g_512qam = @(input) qamdemod(input, 512, 'outputtype', 'bit');  % 512-QAM
    g_1024qam = @(input) qamdemod(input, 1024, 'outputtype', 'bit');  % 512-QAM
    g_mil188qam = @(input) mil188qammod(input,32,'inputtype','bit');  % Mil188-32-QAM


    %%%%%%%% TRANSMITTER   
    
    % Prepare image for transmission by converting it into a binary sequence 
    % in=imread('leaf.png');  
    in=imread('cat.jpg');
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
    y_512qam = h_512qam(input);
    y_1024qam = h_1024qam(input);
    y_mil188qam = h_mil188qam(input);
   
    
    %%%%%%%%%%%%%% CHANNEL 
    
    % Frequency-Domain Signals (modulated symbols) >> Time-Domain using IFFT
    ifft_out_bpsk=ifft(y_bpsk);
    ifft_out_qpsk=ifft(y_qpsk);   
    ifft_out_16qam=ifft(y_16qam);
    ifft_out_64qam=ifft(y_64qam);
    ifft_out_256qam=ifft(y_256qam);
    ifft_out_512qam=ifft(y_512qam);
    ifft_out_1024qam=ifft(y_1024qam);
    ifft_out_mil188qam=ifft(y_mil188qam);

    % Add AWGN to Signals
    SNR=SNR_list(i);          % SNR in dB
    tx_bpsk = awgn(ifft_out_bpsk,SNR,'measured');
    tx_qpsk = awgn(ifft_out_qpsk,SNR,'measured');
    tx_16qam = awgn(ifft_out_16qam,SNR,'measured');
    tx_64qam = awgn(ifft_out_64qam,SNR,'measured');
    tx_256qam = awgn(ifft_out_256qam,SNR,'measured');
    tx_512qam = awgn(ifft_out_512qam,SNR,'measured');
    tx_1024qam = awgn(ifft_out_1024qam,SNR,'measured');
    tx_mil188qam = awgn(ifft_out_mil188qam,SNR,'measured');


    %%%%%%%%%%%%    RECEIVER
    
    % Received signal is processed by applying the FFT to convert back to frequency domain 
    k_bpsk=fft(tx_bpsk);
    k_qpsk=fft(tx_qpsk);
    k_16qam=fft(tx_16qam);
    k_64qam=fft(tx_64qam);
    k_256qam=fft(tx_256qam);
    k_512qam=fft(tx_512qam);
    k_1024qam=fft(tx_1024qam);
    k_mil188qam=fft(tx_mil188qam);

    % Received singal is demodulated
    l_bpsk = pskdemod(k_bpsk, 2, 0, 'outputtype', 'bit'); 
    l_qpsk = pskdemod(k_qpsk, 4, pi/4, 'outputtype', 'bit');
    l_16qam = qamdemod(k_16qam, 16, 'outputtype', 'bit'); 
    l_64qam = qamdemod(k_64qam, 64, 'outputtype', 'bit');
    l_256qam = qamdemod(k_256qam, 256, 'outputtype', 'bit');
    l_512qam = qamdemod(k_512qam, 512, 'outputtype', 'bit');
    l_1024qam = qamdemod(k_1024qam, 1024, 'outputtype', 'bit');
    l_mil188qam = qamdemod(k_mil188qam, 32, 'outputtype', 'bit');

    output_bpsk=uint8(l_bpsk);
    output_qpsk=uint8(l_qpsk);
    output_16qam=uint8(l_16qam);
    output_64qam=uint8(l_64qam);
    output_256qam=uint8(l_256qam);
    output_512qam=uint8(l_512qam);
    output_1024qam=uint8(l_1024qam);
    output_mil188qam=uint8(l_mil188qam);

    output_bpsk=output_bpsk(1:len);
    output_qpsk=output_qpsk(1:len);
    output_16qam=output_16qam(1:len);
    output_64qam=output_64qam(1:len);
    output_256qam=output_256qam(1:len);
    output_512qam=output_512qam(1:len);
    output_1024qam=output_1024qam(1:len);
    output_mil188qam=output_mil188qam(1:len);

    b_bpsk = reshape(output_bpsk, 8, N)';  % Reshape BPSK output into 8-bit blocks
    b1=reshape(output_qpsk,8,N)';
    b2=reshape(output_16qam,8,N)';
    b3=reshape(output_64qam,8,N)';
    b4=reshape(output_256qam,8,N)';
    b5=reshape(output_512qam,8,N)';
    b6=reshape(output_1024qam,8,N)';
    b7=reshape(output_mil188qam,8,N)';

    dec_bpsk = bi2de(b_bpsk,'left-msb');
    dec_qpsk = bi2de(b1,'left-msb');
    dec_16qam = bi2de(b2,'left-msb');
    dec_64qam = bi2de(b3,'left-msb');
    dec_256qam = bi2de(b4,'left-msb');
    dec_512qam = bi2de(b5,'left-msb');
    dec_1024qam = bi2de(b6,'left-msb');
    dec_mil188qam = bi2de(b7,'left-msb');

    % Compute the bit error rate
    BER_bpsk = biterr(input, l_bpsk) / len;
    BER_qpsk = biterr(input, l_qpsk) / len;
    BER_16qam = biterr(input, l_16qam) / len;
    BER_64qam = biterr(input, l_64qam) / len;
    BER_256qam = biterr(input, l_256qam) / len;
    BER_512qam = biterr(input, l_512qam) / len;
    BER_1024qam = biterr(input, l_1024qam) / len;
    BER_mil188qam = biterr(input, l_mil188qam) / len;

    % Save the BER to text log files for each modulation scheme
    disp(BER_1024qam);
    fileID = fopen('logs/1024-QAM_BER.txt', 'a'); % Open file for writing
    fprintf(fileID, '%.8f\n', BER_1024qam); % Write variable with formatting
    fclose(fileID); % Close the file

    disp(BER_512qam);
    fileID = fopen('logs/512-QAM_BER.txt', 'a'); % Open file for writing
    fprintf(fileID, '%.8f\n', BER_512qam); % Write variable with formatting
    fclose(fileID); % Close the file

    % Save the BER to text log files for each modulation scheme
    disp(BER_256qam);
    fileID = fopen('logs/256-QAM_BER.txt', 'a'); % Open file for writing
    fprintf(fileID, '%.8f\n', BER_256qam); % Write variable with formatting
    fclose(fileID); % Close the file

    disp(BER_64qam);
    fileID = fopen('logs/64-QAM_BER.txt', 'a'); % Open file for writing
    fprintf(fileID, '%.8f\n', BER_64qam); % Write variable with formatting
    fclose(fileID); % Close the file

    disp(BER_16qam);
    fileID = fopen('logs/16-QAM_BER.txt', 'a'); % Open file for writing
    fprintf(fileID, '%.8f\n', BER_16qam); % Write variable with formatting
    fclose(fileID); % Close the file

    disp(BER_bpsk);
    fileID = fopen('logs/QPSK_BER.txt', 'a'); % Open file for writing
    fprintf(fileID, '%.8f\n', BER_bpsk); % Write variable with formatting
    fclose(fileID); % Close the file

    disp(BER_qpsk);
    fileID = fopen('logs/BPSK_BER.txt', 'a'); % Open file for writing
    fprintf(fileID, '%.8f\n', BER_qpsk); % Write variable with formatting
    fclose(fileID); % Close the file

    disp(BER_mil188qam);
    fileID = fopen('logs/MILL188-32-QAM_BER.txt', 'a'); % Open file for writing
    fprintf(fileID, '%.8f\n', BER_mil188qam); % Write variable with formatting
    fclose(fileID); % Close the file

    
end