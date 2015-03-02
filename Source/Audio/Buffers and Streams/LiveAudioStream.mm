//==============================================================================
//
//  LiveAudioStream.mm
//  BeatMotion
//
//  Created by Govinda Ram Pingali on 3/7/14.
//  Copyright (c) 2014 BeatMotionLLC. All rights reserved.
//
//==============================================================================


#include "LiveAudioStream.h"


LiveAudioStream::LiveAudioStream(AudioDeviceManager& sharedDeviceManager)   :   deviceManager(sharedDeviceManager)
{
    //--- Audio Device Settings ---//
    deviceManager.getAudioDeviceSetup(deviceSetup);
    
    audioEffectSource.clear();
    m_pbBypassStateArray.clear();
}



LiveAudioStream::~LiveAudioStream()
{
    deviceManager.removeAudioCallback(this);
    audioEffectSource.clear();
    m_pbBypassStateArray.clear();
}




void LiveAudioStream::audioDeviceAboutToStart(AudioIODevice* device)
{
    if (audioEffectSource.size() > 0)
    {
        for (int effectNo = 0; effectNo < audioEffectSource.size(); effectNo++)
        {
            audioEffectSource.getUnchecked(effectNo)->audioDeviceAboutToStart(float(device->getCurrentSampleRate()));
        }
        
    }
}



void LiveAudioStream::audioDeviceStopped()
{
    
}




//==============================================================================
// Process Block
// !!! Running on Audio Thread
//==============================================================================

void LiveAudioStream::audioDeviceIOCallback( const float** inputChannelData,
                                        int totalNumInputChannels,
                                        float** outputChannelData,
                                        int totalNumOutputChannels,
                                        int blockSize)
{
    
    
    // Copy Input Buffer to Output
    for (int sample = 0; sample < blockSize; sample++)
    {
        for (int channel = 0; channel < totalNumInputChannels; channel++)
        {
            outputChannelData[channel][sample] = inputChannelData[channel][sample];
        }
    }
    
    
    // Iterate through effects and process
    if (audioEffectSource.size() > 0)
    {
        for (int effectNo = 0; effectNo < audioEffectSource.size(); effectNo++)
        {
            if (m_pbBypassStateArray[effectNo] == false)
            {
                audioEffectSource.getUnchecked(effectNo)->process(outputChannelData, blockSize);
            }
            
        }
        
    }
    
}


//==============================================================================
// Set Audio Effect Parameter
// !!! Called on Audio Thread
//==============================================================================

void LiveAudioStream::setParameter(int sampleID, int effectID, int parameterID, float value)
{
    
    
}





//==============================================================================
// Add and Remove Audio Effect
// Will pause playback for an instant and restart
//==============================================================================

void LiveAudioStream::addAudioEffect(int sampleID, int effectPosition, int effectID)
{
    if (effectID == 0)
    {
        audioEffectSource.set(effectPosition, nullptr);
    }
    
    
    else
    {
        if (effectPosition < NUM_EFFECTS_SLOTS)
        {
            audioEffectSource.set(effectPosition, new AudioEffectSource(effectID, 2));
        }
    }
}


void LiveAudioStream::removeAudioEffect(int sampleID, int effectPosition)
{
    audioEffectSource.set(effectPosition, nullptr);
}
