% This is the entry point of this code repository.
% 
% The 5 scripts "mainX" called below correspond to the simulation
% procedures used for the 5 different scenarios of the corresponding paper
% available at: https://hal.science/hal-03935561/ .
%

fid = fopen('results_output.txt', 'w');

mainA;
fprintf(fid, '\nScenario A\n----------\n');
fprintf(fid, 'position [mm]:\n');
fprintf(fid, '   - median:     %.2e\n',position_error_median_mm);
fprintf(fid, '   - low 95 CI:  %.2e\n',position_error_95CI_mm(1));
fprintf(fid, '   - high 95 CI: %.2e\n',position_error_95CI_mm(2));
fprintf(fid, 'orientation [deg]:\n');
fprintf(fid, '   - median:     %.2e\n',orientation_error_median_deg);
fprintf(fid, '   - low 95 CI:  %.2e\n',orientation_error_95CI_deg(1));
fprintf(fid, '   - high 95 CI: %.2e\n\n',orientation_error_95CI_deg(2));

mainB;
fprintf(fid, '\nScenario B\n----------\n');
fprintf(fid, 'position [mm]:\n');
fprintf(fid, '   - median:     %.2e\n',position_error_median_mm);
fprintf(fid, '   - low 95 CI:  %.2e\n',position_error_95CI_mm(1));
fprintf(fid, '   - high 95 CI: %.2e\n',position_error_95CI_mm(2));
fprintf(fid, 'orientation [deg]:\n');
fprintf(fid, '   - median:     %.2e\n',orientation_error_median_deg);
fprintf(fid, '   - low 95 CI:  %.2e\n',orientation_error_95CI_deg(1));
fprintf(fid, '   - high 95 CI: %.2e\n\n',orientation_error_95CI_deg(2));

mainC;
fprintf(fid, '\nScenario C\n----------\n');
fprintf(fid, 'position [mm]:\n');
fprintf(fid, '   - median:     %.2e\n',position_error_median_mm);
fprintf(fid, '   - low 95 CI:  %.2e\n',position_error_95CI_mm(1));
fprintf(fid, '   - high 95 CI: %.2e\n',position_error_95CI_mm(2));
fprintf(fid, 'orientation [deg]:\n');
fprintf(fid, '   - median:     %.2e\n',orientation_error_median_deg);
fprintf(fid, '   - low 95 CI:  %.2e\n',orientation_error_95CI_deg(1));
fprintf(fid, '   - high 95 CI: %.2e\n\n',orientation_error_95CI_deg(2));

mainD;
fprintf(fid, '\nScenario D\n----------\n');
fprintf(fid, 'position [mm]:\n');
fprintf(fid, '   - median:     %.2e\n',position_error_median_mm);
fprintf(fid, '   - low 95 CI:  %.2e\n',position_error_95CI_mm(1));
fprintf(fid, '   - high 95 CI: %.2e\n',position_error_95CI_mm(2));
fprintf(fid, 'orientation [deg]:\n');
fprintf(fid, '   - median:     %.2e\n',orientation_error_median_deg);
fprintf(fid, '   - low 95 CI:  %.2e\n',orientation_error_95CI_deg(1));
fprintf(fid, '   - high 95 CI: %.2e\n\n',orientation_error_95CI_deg(2));

mainE;
fprintf(fid, '\nScenario E\n----------\n');
fprintf(fid, 'position [mm]:\n');
fprintf(fid, '   - median:     %.2e\n',position_error_median_mm);
fprintf(fid, '   - low 95 CI:  %.2e\n',position_error_95CI_mm(1));
fprintf(fid, '   - high 95 CI: %.2e\n',position_error_95CI_mm(2));
fprintf(fid, 'orientation [deg]:\n');
fprintf(fid, '   - median:     %.2e\n',orientation_error_median_deg);
fprintf(fid, '   - low 95 CI:  %.2e\n',orientation_error_95CI_deg(1));
fprintf(fid, '   - high 95 CI: %.2e\n\n',orientation_error_95CI_deg(2));

fclose(fid);
