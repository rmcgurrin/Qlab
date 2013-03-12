% timeDomain
function ExpScripter(expName)

import MeasFilters.*

exp = ExpManager();

global dataNamer
deviceName = 'Syracuse_V5.2';
if ~isa(dataNamer, 'DataNamer')
    dataNamer = DataNamer(getpref('qlab', 'dataDir'), deviceName);
end
if ~strcmp(dataNamer.deviceName, deviceName)
    dataNamer.deviceName = deviceName;
    reset(dataNamer);
end
exp.dataFileHandler = HDF5DataHandler(dataNamer.get_name(expName));

expSettings = jsonlab.loadjson(fullfile(getpref('qlab', 'cfgDir'), 'scripter.json'));
instrSettings = expSettings.instruments;
sweepSettings = expSettings.sweeps;
measSettings = expSettings.measurements;

for instrument = fieldnames(instrSettings)'
    instr = InstrumentFactory(instrument{1});
    add_instrument(exp, instrument{1}, instr, instrSettings.(instrument{1}));
end

for sweep = fieldnames(sweepSettings)'
    add_sweep(exp, SweepFactory(sweepSettings.(sweep{1}), exp.instruments));
end

dh1 = DigitalHomodyne(measSettings.M1);
add_measurement(exp, 'M1', dh1);
% dh2 = DigitalHomodyne(measSettings.M2);
% add_measurement(exp, 'M2', dh2);
% 
% add_measurement(exp, 'M12', Correlator(dh1, dh2));

exp.init();
exp.run();

end