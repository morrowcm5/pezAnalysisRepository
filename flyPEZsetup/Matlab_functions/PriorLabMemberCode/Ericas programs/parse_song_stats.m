function [Stats2Plot, AllStats] = parse_song_stats(Data,pulse_cut_offs,sines,Pulses,pulses,IpiTrains,Pauses,Bouts,pulseMFFT,sineMFFT,culled_ipi,culled_End2Peakipi,culled_End2Startipi,PulseModelMFFT,ipiDist)
    numEventCutoff = 50;
    OldPulseModel = Pulses.OldPulseModel;
    pauseThreshold = 0.5e4; %minimum pause between bouts

    %Total recording, sine, pulse, bouts
    %recording_duration = length(Data.d);
    recording_duration = pulse_cut_offs(2) - pulse_cut_offs(1);
    if numel(sines.start) > 0
        in_range_logic = sines.stop <= pulse_cut_offs(2) & sines.start >= pulse_cut_offs(1);
        SineTrainNum = numel(sines.start(in_range_logic));
        SineTrainLengths = (sines.stop(in_range_logic) - sines.start(in_range_logic));
        SineTotal = sum(SineTrainLengths);
    else
        SineTrainNum = 0;
        SineTrainLengths = 0;
        SineTotal = 0;
    end

    if numel(IpiTrains.t) > 0
        IpiTrains.t = cellfun(@(x)  x(x <= pulse_cut_offs(2) & x >= pulse_cut_offs(1)), IpiTrains.t,'uniformoutput',false);
        IpiTrains.t(cellfun(@(x) isempty(x), IpiTrains.t)) = [];

        PulseTrainNum = numel(IpiTrains.t);
        PulseTrainLengths = cellfun(@(x) x(end)-x(1), IpiTrains.t);
        PulseTotal = sum(PulseTrainLengths);
    else
        PulseTrainNum = 0;
        PulseTrainLengths = 0;
        PulseTotal = 0;
    end

    %Transition probabilities

    NumSine2PulseTransitions = sum(Pauses.sinepulse<pauseThreshold);
    NumPulse2SineTransitions = sum(Pauses.pulsesine<pauseThreshold);
    NumTransitions = NumSine2PulseTransitions + NumPulse2SineTransitions;


    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    %# pulse trains/min - DONE

    PulseTrainsPerMin = PulseTrainNum  * 60/(recording_duration / Data.fs);

    %pulses / min - DONE

    PulsesPerMin = PulseTotal * 60/(recording_duration / Data.fs);

    %# sine trains / min - DONE

    SineTrainsPerMin = SineTrainNum * 60 /(recording_duration / Data.fs);

    %sine / min - DONE

    SinePerMin = SineTotal * 60/(recording_duration / Data.fs);

    %total % bouts / min - DONE

    in_range_logic = Bouts.Stop <= pulse_cut_offs(2) & Bouts.Start >= pulse_cut_offs(1);
    BoutsPerMin = numel(Bouts.Start(in_range_logic)) * 60 / (recording_duration / Data.fs);

    %total song / min 

    SongPerMin = (PulseTotal + SineTotal) * 60/(recording_duration / Data.fs);

    % Sine/Pulse within bout Transition Probabilities - DONE

    if NumTransitions > 0
        %Sine2PulseTransProb = NumSine2PulseTransitions / NumTransitions;
        TransProb = TranProb(Data,sines,pulses);

        NullToSine = TransProb(1,2);
        SineToNull = TransProb(2,1);
        if size(TransProb,1) == 2
            NullToPulse = 0;    
            PulseToNull = 0;
            SineToPulse = 0;
            PulseToSine = 0;        
        else
            NullToPulse = TransProb(1,3);    
            PulseToNull = TransProb(3,1);
            SineToPulse = TransProb(2,3);
            PulseToSine = TransProb(3,2);
        end
    %     NulltoSongTransProb = [TransProb(1,2) TransProb(1,3)];
    %     SinetoPulseTransProb = [TransProb(2,3) TransProb(3,2)];
    else
        NullToSine = NaN;
        NullToPulse = NaN;
        SineToNull = NaN;
        PulseToNull = NaN;
        SineToPulse = NaN;
        PulseToSine = NaN;
    %     NulltoSongTransProb = [NaN NaN];
    %     SinetoPulseTransProb = [NaN NaN];
    end

    %mode pulse train length (sec) - DONE

    try
        MedianPulseTrainLength = median(PulseTrainLengths) / Data.fs;
    catch
        MedianPulseTrainLength = NaN;
    end

    %mode sine train length (sec) - DONE

    try
        MedianSineTrainLength = median(SineTrainLengths)/ Data.fs;
    catch
        MedianSineTrainLength = NaN;
    end

    %ratio sine to pulse - DONE

    if PulseTotal > 0
        Sine2Pulse = SineTotal ./ PulseTotal;
        Sine2PulseNorm = [log10(sqrt(SineTotal.* PulseTotal)./(recording_duration-SineTotal-PulseTotal)) log10(Sine2Pulse)];
    else
        Sine2Pulse = NaN;
        Sine2PulseNorm = [NaN NaN];
    end

    %ratio sine to pulse per bout ---- TO DO -----



    %mode pulse carrier freq - DONE

    try
        if numel(pulseMFFT.freqAll) > numEventCutoff
            ModePulseMFFT = kernel_mode(pulseMFFT.freqAll,min(pulseMFFT.freqAll):.1:max(pulseMFFT.freqAll));
        else
            ModePulseMFFT = NaN;
        end
    catch
        ModePulseMFFT = NaN;
    end

    %mode sine carrier freq if have at least 100 samples - DONE
    try
        if numel(sineMFFT.freqAll) > numEventCutoff
            ModeSineMFFT = kernel_mode(sineMFFT.freqAll,min(sineMFFT.freqAll):.1:max(sineMFFT.freqAll));
        else
            ModeSineMFFT = NaN;
        end
    catch
        ModeSineMFFT = NaN;
    end


    %mode Peak2PeakIPI - DONE
    try
        if numel(culled_ipi.d) > numEventCutoff
            ModePeak2PeakIPI = kernel_mode(culled_ipi.d,min(culled_ipi.d):1:max(culled_ipi.d))./10;
        else
            ModePeak2PeakIPI = NaN;
        end
    catch
        ModePeak2PeakIPI = NaN;
    end

    %mode Peak2PeakIPI - DONE
    try
        if numel(culled_End2Peakipi.d) > numEventCutoff
        ModeEnd2PeakIPI = kernel_mode(culled_End2Peakipi.d,min(culled_End2Peakipi.d):1:max(culled_End2Peakipi.d))./10;
        else
            ModeEnd2PeakIPI  = NaN;
        end
    catch
        ModeEnd2PeakIPI = NaN;
    end

    %mode Peak2PeakIPI - DONE
    try
        if numel(culled_End2Startipi.d) > numEventCutoff
        ModeEnd2StartIPI = kernel_mode(culled_End2Startipi.d,min(culled_End2Startipi.d):1:max(culled_End2Startipi.d))./10;
        else
            ModeEnd2StartIPI = NaN;
        end
    catch
        ModeEnd2StartIPI = NaN;
    end

    %mode Peak2PeakIPI controlled for temperature
    %resid = ipi- m * temp - intercept
    %m and intercept come from modeling control data
    %m = -0.9701
    %intercept = 64.533

    % if ~isnan(ModePeak2PeakIPI) && ~isnan(temphyg(1))
    %     residIPI = ModePeak2PeakIPI + (0.9701 * temphyg(1)) - 64.533;
    % else
    %     residIPI  = NaN;
    % end
    residIPI  = NaN;



    %skewness of IPI - DONE

    SkewnessIPI = skewness(culled_ipi.d,0);

    %mode of LLRfh fits > 0 of pulses to model - to find odd pulse shapes -
    %DONE

    try
        if numel(Pulses.Lik_pulse2.LLR_fh) > numEventCutoff
        LLRfh = Pulses.Lik_pulse2.LLR_fh(Pulses.Lik_pulse2.LLR_fh > 0);
        MedianLLRfh = median(LLRfh);
        else
            MedianLLRfh  = NaN;
        end

    catch
        MedianLLRfh = NaN;
    end

    %mode of amplitude of pulses - DONE

    try
        if numel(pulses.x) > numEventCutoff
        PulseAmplitudes = cellfun(@(y) sqrt(mean(y.^2)),pulses.x);
        MedianPulseAmplitudes = median(PulseAmplitudes);
        else
            MedianPulseAmplitudes = NaN;
        end
    catch
        MedianPulseAmplitudes = NaN;
    end

    %mode of amplitude of sine - DONE

    try
        if numel(sineMFFT.freqAll) > numEventCutoff
        SineAmplitudes = cellfun(@(y) sqrt(mean(y.^2)),sines.clips);
        MedianSineAmplitudes = kernel_mode(SineAmplitudes,min(SineAmplitudes):.0001:max(SineAmplitudes));
        else
            MedianSineAmplitudes = NaN;
        end
    catch
        MedianSineAmplitudes = NaN;
    end

    %pulse model - DONE

    PulseModels.OldMean = OldPulseModel.fhM;
    PulseModels.OldStd = OldPulseModel.fhS;
    PulseModels.NewMean = Pulses.pulse_model2.newfhM;
    PulseModels.NewStd = Pulses.pulse_model2.newfhS;

    %slope of sine carrier freq within bouts
    numBouts = numel(Bouts.Start);
    if numBouts >0

        [time,freq] = SineFFTTrainsToBouts(Bouts,sines,sineMFFT,4);
        corrs = cellfun(@(x,y) corr(x',y),time,freq);

        if ~isempty(corrs)
            CorrSineFreqDynamics = kernel_mode(corrs,min(corrs):.1:max(corrs));
        else
            CorrSineFreqDynamics = NaN;
        end

    else
    %    SlopeSineFreqDynamics = NaN;
        CorrSineFreqDynamics = NaN;
        time = NaN;
        freq = NaN;
    end

    %corr coef of bout duration vs recording time
    try
        CorrBoutDuration = corr(Bouts.Start,(Bouts.Stop - Bouts.Start));
    catch
        CorrBoutDuration = NaN;
    end

    %corr coef of pulse train duration vs recording time
    try
        pulseTrains.start = zeros(numel(IpiTrains.t),1);
        pulseTrains.stop = pulseTrains.start;
        for i = 1:numel(IpiTrains.t)
            pulseTrains.start(i) = IpiTrains.t{i}(1);
            pulseTrains.stop(i) = IpiTrains.t{i}(end);
        end
        CorrPulseTrainDuration = corr(pulseTrains.start,pulseTrains.stop - pulseTrains.start);
    catch
        CorrPulseTrainDuration = NaN;
    end


    %corr coef of sine train duration vs recording time
    try
        CorrSineTrainDuration = corr(Sines.LengthCull.start,Sines.LengthCull.stop-Sines.LengthCull.start);
    catch
        CorrSineTrainDuration = NaN;
    end

    %corr coef of sine carrier freq vs recording time
    try
        CorrSineFreq = corr(sineMFFT.timeAll',sineMFFT.freqAll);
    catch
        CorrSineFreq = NaN;
    end

    %corr coef of pulse carrier freq vs recording time
    try
        CorrPulseFreq = corr(pulseMFFT.timeAll',pulseMFFT.freqAll');
    catch
        CorrPulseFreq = NaN;
    end
    %corr coef of IPI vs recording time
    try
        CorrIpi = corr(culled_ipi.t',culled_ipi.d');
    catch
        CorrIpi = NaN;
    end

    %Lomb-Scargle of IPIs
    try
        [lombStats] = calcLomb(culled_ipi,Data.fs,0.01);
    catch
        lombStats.F = [];
        lombStats.Alpha = [];
        lombStats.Peaks = [];
    end


    %timestamp

    timestamp = datestr(now,'yyyymmddHHMMSS');

    %Stats2Plot.ipi = ipi;
    %Stats2Plot.culled_ipi = culled_ipi;

    Stats2Plot.PulseTrainsPerMin = PulseTrainsPerMin;
    Stats2Plot.PulsesPerMin = PulsesPerMin;
    Stats2Plot.SineTrainsPerMin = SineTrainsPerMin;
    Stats2Plot.SinePerMin = SinePerMin;
    Stats2Plot.BoutsPerMin = BoutsPerMin;
    Stats2Plot.SongPerMin = SongPerMin;
    Stats2Plot.NullToSine = NullToSine;
    Stats2Plot.NullToPulse = NullToPulse;

    Stats2Plot.SineToNull = SineToNull;
    Stats2Plot.PulseToNull = PulseToNull;
    Stats2Plot.SineToPulse = SineToPulse;
    Stats2Plot.PulseToSine = PulseToSine;
    % Stats2Plot.NulltoSongTransProb = NulltoSongTransProb;
    % Stats2Plot.SinetoPulseTransProb = SinetoPulseTransProb;%and pulse2sine
    %Stats2Plot.Pulse2SineTransProb = Pulse2SineTransProb;
    Stats2Plot.MedianPulseTrainLength = MedianPulseTrainLength;

    Stats2Plot.MedianSineTrainLength = MedianSineTrainLength;
    Stats2Plot.Sine2Pulse = Sine2Pulse;
    Stats2Plot.Sine2PulseNorm = Sine2PulseNorm;
    %Stats2Plot.ModePulseMFFT = ModePulseMFFT;
    Stats2Plot.PulseModelMFFT = PulseModelMFFT;
    Stats2Plot.ModeSineMFFT = ModeSineMFFT;

    Stats2Plot.MedianLLRfh = MedianLLRfh;
    Stats2Plot.ModePeak2PeakIPI = ModePeak2PeakIPI;
    Stats2Plot.ModeEnd2PeakIPI = ModeEnd2PeakIPI;
    Stats2Plot.ModeEnd2StartIPI = ModeEnd2StartIPI;
    Stats2Plot.ipiDist = ipiDist;
    %Stats2Plot.SkewnessIPI = SkewnessIPI;
    %Stats2Plot.residIPI = residIPI;
    Stats2Plot.MedianPulseAmplitudes = MedianPulseAmplitudes;

    Stats2Plot.MedianSineAmplitudes = MedianSineAmplitudes;
    Stats2Plot.CorrSineFreqDynamics=CorrSineFreqDynamics;
    % Stats2Plot.CorrBoutDuration=CorrBoutDuration;
    % Stats2Plot.CorrPulseTrainDuration=CorrPulseTrainDuration;
    % Stats2Plot.CorrSineTrainDuration=CorrSineTrainDuration;
    % 
    % Stats2Plot.CorrSineFreq=CorrSineFreq;
    % Stats2Plot.CorrPulseFreq=CorrPulseFreq;
    % Stats2Plot.CorrIpi=CorrIpi;
    Stats2Plot.lombStats=lombStats;
    Stats2Plot.PulseModels = PulseModels;

    Stats2Plot.timestamp = timestamp;

    Stats2Plot.SineFFTBouts.time = time;
    Stats2Plot.SineFFTBouts.freq = freq;



    AllStats.PulseTrainsPerMin = PulseTrainsPerMin;
    AllStats.PulsesPerMin = PulsesPerMin;
    AllStats.SineTrainsPerMin = SineTrainsPerMin;
    AllStats.SinesPerMin = SinePerMin;
    AllStats.BoutsPerMin = BoutsPerMin;
    AllStats.SongPerMin = SongPerMin;
    %AllStats.TransProb = TransProb;
    AllStats.NullToSine = NullToSine;%transition probabilities
    AllStats.NullToPulse = NullToPulse;
    AllStats.SineToNull = SineToNull;
    AllStats.PulseToNull = PulseToNull;
    AllStats.SineToPulse = SineToPulse;
    AllStats.PulseToSine = PulseToSine;

    AllStats.MedianPulseTrainLength = MedianPulseTrainLength;
    AllStats.MedianSineTrainLength = MedianSineTrainLength;
    AllStats.Sine2Pulse = Sine2Pulse;
    AllStats.Sine2PulseNorm = Sine2PulseNorm;
    AllStats.ModePulseMFFT = ModePulseMFFT;
    AllStats.PulseModelMFFT = PulseModelMFFT;
    AllStats.ModeSineMFFT = ModeSineMFFT;
    AllStats.ModePeak2PeakIPI = ModePeak2PeakIPI;
    AllStats.ModeEnd2PeakIPI = ModeEnd2PeakIPI;
    AllStats.ModeEnd2StartIPI = ModeEnd2StartIPI;
    AllStats.ipiDist = ipiDist;
    AllStats.residIPI = residIPI;
    AllStats.SkewnessIPI = SkewnessIPI;
    AllStats.MedianLLRfh = MedianLLRfh;
    AllStats.MedianPulseAmplitudes = MedianPulseAmplitudes;
    AllStats.MedianSineAmplitudes = MedianSineAmplitudes;
    AllStats.CorrSineFreqDynamics=CorrSineFreqDynamics;
    AllStats.CorrBoutDuration=CorrBoutDuration;
    AllStats.CorrPulseTrainDuration=CorrPulseTrainDuration;
    AllStats.CorrSineTrainDuration=CorrSineTrainDuration;
    AllStats.CorrSineFreq=CorrSineFreq;
    AllStats.CorrPulseFreq=CorrPulseFreq;
    AllStats.CorrIpi=CorrIpi;
    AllStats.lombStats=lombStats;

    AllStats.PulseModels = PulseModels;
    AllStats.SineFFTBouts.time = time;
    AllStats.SineFFTBouts.freq = freq;

    %AllStats.temphyg = temphyg;
    %AllStats.filename = filename;
    AllStats.timestamp = timestamp;

end