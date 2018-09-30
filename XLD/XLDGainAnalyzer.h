//
//  XLDGainAnalyzer.h
//  XLD
//
//  Created by tmkk on 2018/03/22.
//
//

#ifndef XLDGainAnalyzer_h
#define XLDGainAnalyzer_h

#include <stdio.h>
#include "gain_analysis.h"
#include "ebur128.h"

typedef enum
{
    XLDGainAnalyzerModeReplayGain,
    XLDGainAnalyzerModeEBUR128
} XLDGainAnalyzerMode;

typedef struct
{
    XLDGainAnalyzerMode mode;
    replaygain_t *rg;
    ebur128_state **r128_album;
    ebur128_state *r128_track;
    double *peaks;
    int tracks;
    int channels;
    int frequency;
} XLDGainAnalyzer;

XLDGainAnalyzer *XLDGainAnalyzer_Init(int frequency, int channels, XLDGainAnalyzerMode mode);
void XLDGainAnalyzer_CommitSamples(XLDGainAnalyzer *state, int *samples, int count);
void XLDGainAnalyzer_GetCurrentTrackGainAndPeak(XLDGainAnalyzer *state, double *gain, double *peak);
void XLDGainAnalyzer_GetAlbumGainAndPeak(XLDGainAnalyzer *state, double *gain, double *peak);
void XLDGainAnalyzer_Destroy(XLDGainAnalyzer **pState);

#endif /* XLDGainAnalyzer_h */
