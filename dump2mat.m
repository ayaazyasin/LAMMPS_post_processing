% LAMMPS dump file parsing script
% Ayaaz Yasin - June 13, 2026
%
%       dump2mat(dumpFile)
%       dump2mat(dumpFile, outFolder)
%
% Inputs:
%       dumpFile ....... (string) name of dump file in current folder.
%       outFolder ...... (string) optional, directory location to save MAT files.
% Outputs:
%       saves a series of MAT-files with column vectors for each timestep.
function dump2mat(dumpFile, varargin)
    if      nargin==2; outFolder = varargin{1};             % save to given folder
    elseif  nargin==1; outFolder = '.';                     % save to current folder
    else;   error('Invalid number of input arguments');
    end
    
    fid             = fopen(dumpFile, 'r');                 % open file
    if fid == -1; error('Cannot open %s',dumpFile); end     % error check
    for i = 1:4; line = fgetl(fid); end                     % read atom count from line four
    fclose(fid);                                            % close file
    nAtoms          = str2double(line);                     % number of atoms
    linesPerStep    = nAtoms+9;                             % number of lines per timestep
    
    fid             = fopen(dumpFile, 'r');                 % open file
    if fid == -1; error('Cannot open %s',dumpFile); end     % error check
    nLines          = 0;                                    % initialization
    while ~feof(fid); fgetl(fid); nLines = nLines+1; end    % total number of lines in file
    fclose(fid);                                            % close file
    
    nSteps          = nLines/linesPerStep;                  % number of timesteps in file
    
    fid             = fopen(dumpFile, 'r');                 % open file
    if fid == -1; error('Cannot open %s',dumpFile); end     % error check
    
    for k = 1:nSteps
        line        = fgetl(fid);                           % ITEM: TIMESTEP
        line        = fgetl(fid);                           % TIMESTEP
        timestep    = str2double(line);                     % current timestep
    
        while true                                          % advance to data lines — scan until "ITEM: ATOMS" header
            line    = fgetl(fid);
            if ~ischar(line); error('Unexpected EOF before ITEM: ATOMS at k=%d', k); end
            if startsWith(line, 'ITEM: ATOMS'); break; end
        end
        
        % dump file columns: id(1) type(2) x(3) y(4) z(5) vx(6) vy(7) vz(8)
        C = textscan(fid,'%f %f %f %f %f %f %f %f',nAtoms); % read data lines for current timestep
        if isempty(C{1}); error('Unexpected EOF at timestep %d (k=%d)', timeStep, k); end
        
        % parse columns as separate variables and save
        id_col=C{1}; type_col=C{2}; x_col=C{3}; y_col=C{4}; z_col=C{5}; vx_col=C{6}; vy_col=C{7}; vz_col=C{8};
        save(sprintf('%s/raw_%d.mat',outFolder, timestep),'id_col','type_col','x_col','y_col','z_col','vx_col','vy_col','vz_col')
        fprintf('  saved timestep %d  (%d/%d)\n', timestep, k, nSteps)
        try line = fgetl(fid); end
    end
    fprintf('done.\n')
    fclose(fid);                                            % close file
end