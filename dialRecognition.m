function decode_result=dialRecognition(phone)
% must separate n numbers in phone audio into a matrix called dialSep of n rows
% rowCount decides which row of dialSep would be defined
n=1;
% if phone starts whti 0, best thing to do first is to eliminate it (in order to
% simplify code)
phone_length=length(phone);
while phone(n)==0
    n=n+1;
end
phone=phone(n:phone_length);
% now separate the phone vector (which contains n dial numbers) into n parts
% and store them in dialSep
% stepCount provide indexes for each cut
n=1;
phone_length=length(phone);
for i=3:phone_length-1
    if ((phone(i-1)~=phone(i)) && ((phone(i)==0&&phone(i+1)==0)||(phone(i-2)==0&&phone(i-1)==0)))
        stepCount(n)=i-1;
        n=n+1;
    end
end
stepCount=[1 stepCount phone_length];
% cutting phone into n pieces
for i=1:2:length(stepCount)-1
    dialSep((i+1)/2,1:stepCount(i+1)-stepCount(i)+1)=phone(stepCount(i):stepCount(i+1));
end
% calculating fft of each dialSep component
% preallocating fftdial
for i=1:length(dialSep(:,1))
    fftDial(i,1:2048)=fft(dialSep(i,:),2048);
end
number_howmany=length(fftDial(:,1));
omegaRow=[0.7217 0.5346 0.5906 0.6535];
omegaColumn=[0.9273 1.0247 1.1328];
kRow=floor(omegaRow*2048/2/pi);
kColumn=floor(omegaColumn*2048/2/pi);
% stem for debug
k=0:2047;
omega=2*pi*k/2048;
for i=1:number_howmany
    subplot(2,4,i)
    stem(omega,fftDial(i,:))
    axis([.5,1.25,-400,400])
    set(gca,'XTick',[0:0.1:1.5])
end
% delete end
% starting to recognise. method is to find out if fftDial is above threshold
% at given k position
% preallocations
fftMax(number_howmany,1)=0;targetRow(number_howmany)=0;targetCol(number_howmany)=0;
% outer for loop towards number of dials
for i=1:number_howmany
    fftMax(i)=max(abs(imag(fftDial(i,162:408))));
    % secondary loop for omegaRow recognition
    for num=1:length(kRow)
        fftMaxMaybe_row=max(abs(imag(fftDial(i,kRow(num)-3:kRow(num)+3))));
        if (fftMaxMaybe_row>=.6*fftMax(i))
            targetRow(i)=num;
        end
    end
    % secondary loop for omegaColumn recogniion
    for num=1:length(kColumn)
        fftMaxMaybe_col=max(abs(imag(fftDial(i,kColumn(num)-3:kColumn(num)+3))));
        if (fftMaxMaybe_col>=.6*fftMax(i,1))
            targetCol(i)=num;
        end
    end
end
% generating final decode result
% preallocation of decode_result
decode_result(number_howmany)=0;
for i=1:number_howmany
    switch targetRow(i)
        case 1
            decode_result(i)=0;
        case 2
            decode_result(i)=targetCol(i);
        case 3
            decode_result(i)=targetCol(i)+3;
        case 4
            decode_result(i)=targetCol(i)+6;
        otherwise
            disp('this is not happening')% just for debug
    end
end