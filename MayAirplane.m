
clc;
clear all;
close all;

filename = 'data_plev.nc'; % ??? ????

% ?????? ???????
ozone = ncread(filename, 'go3');       % ????
no2 = ncread(filename, 'no2');         % ?????????? ????????
no = ncread(filename, 'no');           % ?????? ?????

time_sec = ncread(filename, 'valid_time'); % ???? ?? ????? ?? 1970-01-01
latitude = ncread(filename, 'latitude');
longitude = ncread(filename, 'longitude');

% ????? ???? ?? ????? ?? datetime
time = datetime(1970,1,1,0,0,0) + seconds(time_sec);

% ???????????? ????? (??? ??? ? ??? ?????????)
ozone_mean = squeeze(mean(mean(ozone,1,'omitnan'),2,'omitnan'));
no2_mean = squeeze(mean(mean(no2,1,'omitnan'),2,'omitnan'));
no_mean = squeeze(mean(mean(no,1,'omitnan'),2,'omitnan'));




% ???????? solar_flare ?? ????:
solar_flare = [-2.076923077
-20.53846154,
-34.38461538,
-9.5,
3,
-13.5,
-3.653846154,
6.730769231,
16.84615385,
-39.03846154,
-275.5384615,
-106.3846154,
-60.76923077,
-43.53846154,
-36.84615385,
-53.80769231,
-46.30769231,
-59.26923077,
-28.15384615,
-18.38461538,
-12.23076923,
-2.576923077,
-10.15384615,
-19.34615385,
-7.730769231,
-14.26923077,
-5.423076923,
3.615384615,
15.23076923,
1.884615385,
-18.69230769,
];

% ??? ?? ???? ?? time? ozone_mean? no2_mean? no_mean ?? ??? ????? ??? ? ?????? 31 ???

% ??? ????????
figure (1);

subplot(4,1,1);
hold on;

% ?????? ????? ?????? (y = -90 ?? -150)
fill([time(1), time(end), time(end), time(1)], ...
     [-90, -90, -200, -200], ...
     [1, 0.6, 0], 'FaceAlpha', 0.3, 'EdgeColor', 'none');

% ?????? ????? ??? (y < -150)
fill([time(1), time(end), time(end), time(1)], ...
     [-200, -200, -300, -300], ...
     [1, 0, 0], 'FaceAlpha', 0.2, 'EdgeColor', 'none');

% ?????? ????
plot(time, solar_flare, '-k', 'LineWidth', 1.5);

% ????? ? ????????
title('Dst Values');
ylabel('nT');
grid on;

% ??? ?????? ??? ??????
text(time(3), -100, 'Warning Zone', 'Color', [1 0.5 0], 'FontWeight', 'bold');
text(time(3), -200, 'Serious Alert', 'Color', [0.8 0 0], 'FontWeight', 'bold');

hold off;

subplot(4,1,2);
plot(time, ozone_mean, '-b');
title('Ozone (O3)');
ylabel('kg/m^2');
grid on;

subplot(4,1,3);
plot(time, no2_mean, '-r');
title('NO2 (NO2)');
ylabel('kg/m^2');
grid on;

subplot(4,1,4);
plot(time, no_mean, '-g');
title('NO (NO)');
ylabel('kg/m^2');
xlabel('Time');
grid on;

% ??????? ?? ????? ??????? ????? ?????
solar_flare = solar_flare(:);
ozone_mean = ozone_mean(:);
no2_mean = no2_mean(:);
no_mean = no_mean(:);

% ??? lag ????: 0 ?? +10 ???
max_lag = 10;
lags = 0:max_lag;

% ???? ????? ????? ??????? ?? ?? lag
corr_ozone = zeros(length(lags), 1);
corr_no2 = zeros(length(lags), 1);
corr_no = zeros(length(lags), 1);

% ?????? ??????? ???? ?? lag
for i = 1:length(lags)
    lag = lags(i);

    if lag > 0
        sf = solar_flare(1+lag:end);
        oz = ozone_mean(1:end-lag);
        no2 = no2_mean(1:end-lag);
        no_ = no_mean(1:end-lag);
    else
        sf = solar_flare;
        oz = ozone_mean;
        no2 = no2_mean;
        no_ = no_mean;
    end

    corr_ozone(i) = corr(sf, oz);
    corr_no2(i) = corr(sf, no2);
    corr_no(i) = corr(sf, no_);
end

% ???? ???? ?????? ??????????
[max_oz, idx_oz] = max(abs(corr_ozone));
[max_no2, idx_no2] = max(abs(corr_no2));
[max_no, idx_no] = max(abs(corr_no));

% ????? ????? (?? ??? ????) ?? ???? lag
val_oz = corr_ozone(idx_oz);
val_no2 = corr_no2(idx_no2);
val_no = corr_no(idx_no);

% ??? ??????
figure (2);
plot(lags, corr_ozone, '-bo', 'LineWidth', 2); hold on;
plot(lags, corr_no2, '-rs', 'LineWidth', 2);
plot(lags, corr_no, '-g^', 'LineWidth', 2);
yline(0, '--k');
xlabel('Lag (days)');
ylabel('Correlation coefficient');
title('Lagged Correlation with Solar Flare (Future Days Only)');
legend('Ozone', 'NO?', 'NO', 'Location', 'best');
grid on;

% ????? ??????? ??? ?? ???? ???? ??????
dim = [0.6 0.15 0.3 0.2]; % [x y w h] ???? ?? ?????
str = sprintf(['Peak Correlations:\n' ...
               'O3: %.3f at lag %d\n' ...
               'NO2: %.3f at lag %d\n' ...
               'NO: %.3f at lag %d'], ...
               val_oz, lags(idx_oz), val_no2, lags(idx_no2), val_no, lags(idx_no));
annotation('textbox', dim, 'String', str, ...
           'FitBoxToText', 'on', 'BackgroundColor', 'w', ...
           'EdgeColor', 'k', 'FontSize', 10);

% ????? ?? Command Window
fprintf('\n>> Maximum absolute correlations (future lags only):\n');
fprintf('Ozone: %.3f at lag %d\n', val_oz, lags(idx_oz));
fprintf('NO?: %.3f at lag %d\n', val_no2, lags(idx_no2));
fprintf('NO: %.3f at lag %d\n', val_no, lags(idx_no));
