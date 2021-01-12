clear all
clc

x_AB = 0:1:1192; 
y_AB = ones(1,length(x_AB)).*12500;

x_BC = 1192:1:2383;
y_BC = 12500 - ((12500-6630)/(2383-1192)).* (x_BC-1192);

x_CD = 2383:1:2602;
y_CD = 6630 - 6630/(2602-2383) .* (x_CD - 2383);


plot(x_AB,y_AB,'LineWidth',2,'color','b')
hold on
plot(x_BC,y_BC,'LineWidth',2,'color','b')
hold on
plot(x_CD,y_CD,'LineWidth',2,'color','b')
hold on
grid on
xlabel('Range (nm)')
ylabel('Payload (lb)')
title('Payload-Range Diagram')