//
//  XLDGainAnalyzer.c
//  XLD
//
//  Created by tmkk on 2018/03/22.
//
//

#include <stdlib.h>
#include "XLDGainAnalyzer.h"

XLDGainAnalyzer *XLDGainAnalyzer_Init(int frequency, int channels, XLDGainAnalyzerMode mode)
{
    XLDGainAnalyzer *state = calloc(1, sizeof(XLDGainAnalyzer));
    state->mode = mode;
    state->channels = channels;
    state->frequency = frequency;
    if(mode == XLDGainAnalyzerModeReplayGain) {
        state->rg = malloc(sizeof(replaygain_t));
        gain_init_analysis(state->rg, frequency);
    }
    else if(mode == XLDGainAnalyzerModeEBUR128) {
        state->r128_track = ebur128_init(channels, frequency, EBUR128_MODE_I|EBUR128_MODE_SAMPLE_PEAK);
    }
    else {
        free(state);
        return NULL;
    }
    return state;
}

void XLDGainAnalyzer_CommitSamples(XLDGainAnalyzer *state, int *samples, int count)
{
    if(state->mode == XLDGainAnalyzerModeReplayGain) {
        gain_analyze_samples_interleaved_int32(state->rg, samples, count, state->channels);
    }
    else if(state->mode == XLDGainAnalyzerModeEBUR128) {
        ebur128_add_frames_int(state->r128_track, samples, count);
    }
}

void XLDGainAnalyzer_GetCurrentTrackGainAndPeak(XLDGainAnalyzer *state, double *gain, double *peak)
{
    if(state->mode == XLDGainAnalyzerModeReplayGain) {
        *gain = PINK_REF-gain_get_title(state->rg);
        *peak = peak_get_title(state->rg);
    }
    else if(state->mode == XLDGainAnalyzerModeEBUR128) {
        int i;
        double trackGain, trackPeak;
        ebur128_loudness_global(state->r128_track, &trackGain);
        *gain = ebur128_reference_loudness - trackGain;
        *peak = 0;
        for(i=0;i<state->channels;i++) {
            ebur128_sample_peak(state->r128_track, i, &trackPeak);
            if(trackPeak > *peak) *peak = trackPeak;
        }
        if(!state->tracks) {
            state->r128_album = malloc(sizeof(ebur128_state*));
            state->peaks = malloc(sizeof(double));
        }
        else {
            state->r128_album = realloc(state->r128_album, sizeof(ebur128_state*)*(state->tracks+1));
            state->peaks = realloc(state->peaks, sizeof(double)*(state->tracks+1));
        }
        state->r128_album[state->tracks] = state->r128_track;
        state->peaks[state->tracks++] = *peak;
        state->r128_track = ebur128_init(state->channels, state->frequency, EBUR128_MODE_I|EBUR128_MODE_SAMPLE_PEAK);
    }
}

void XLDGainAnalyzer_GetAlbumGainAndPeak(XLDGainAnalyzer *state, double *gain, double *peak)
{
    if(state->mode == XLDGainAnalyzerModeReplayGain) {
        *gain = PINK_REF-gain_get_album(state->rg);
        *peak = peak_get_album(state->rg);
    }
    else if(state->mode == XLDGainAnalyzerModeEBUR128) {
        int i;
        double albumGain;
        ebur128_loudness_global_multiple(state->r128_album, state->tracks, &albumGain);
        *gain = ebur128_reference_loudness - albumGain;
        *peak = 0;
        for(i=0;i<state->tracks;i++) {
            if(state->peaks[i] > *peak) *peak = state->peaks[i];
        }
    }
}

void XLDGainAnalyzer_Destroy(XLDGainAnalyzer **pState)
{
    if(!!pState) return;
    XLDGainAnalyzer *state = *pState;
    int i;
    for(i=0;i<state->tracks;i++) ebur128_destroy(&state->r128_album[i]);
    if(state->rg) free(state->rg);
    if(state->r128_album) free(state->r128_album);
    if(state->peaks) free(state->peaks);
    if(state->r128_track) ebur128_destroy(&state->r128_track);
    free(state);
    *pState = NULL;
}
