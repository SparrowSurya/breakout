import wave
import math
import struct
import os

SAMPLE_RATE = 44100
DURATION = 10.0 # 10.0s = 16 beats at 96 BPM (4 bars of 4/4)
TOTAL_SAMPLES = int(SAMPLE_RATE * DURATION)
BPM = 96.0
BEAT_DUR = 60.0 / BPM # 0.625s per beat

def midi_to_freq(m):
    return 440.0 * (2.0 ** ((m - 69) / 12.0))

def osc_soft_square(phase, harmonics=7):
    # Bandlimited warm square wave (odd harmonics with roll-off)
    val = 0.0
    for h in range(1, harmonics + 1, 2):
        val += math.sin(h * phase) / (h ** 1.3)
    return val * 0.7

def osc_triangle(phase):
    # Pure triangle wave
    val = 0.0
    for h in range(1, 9, 2):
        sign = -1.0 if ((h - 1) // 2) % 2 else 1.0
        val += sign * math.sin(h * phase) / (h * h)
    return val * 0.8

def osc_sine(phase):
    return math.sin(phase)

def render_wav(filename, left_buf, right_buf):
    # Normalize with headroom
    peak = max(max(abs(s) for s in left_buf), max(abs(s) for s in right_buf))
    if peak > 0:
        gain = 0.85 / peak
        left_buf = [s * gain for s in left_buf]
        right_buf = [s * gain for s in right_buf]
    
    with wave.open(filename, 'wb') as wf:
        wf.setnchannels(2)
        wf.setsampwidth(2)
        wf.setframerate(SAMPLE_RATE)
        frames = bytearray()
        for i in range(TOTAL_SAMPLES):
            l = int(max(-1.0, min(1.0, left_buf[i])) * 32767.0)
            r = int(max(-1.0, min(1.0, right_buf[i])) * 32767.0)
            frames.extend(struct.pack('<hh', l, r))
        wf.writeframes(frames)
    print(f"Generated {filename} ({DURATION}s, {TOTAL_SAMPLES} samples)")

# Helper to schedule looping notes
class SynthEngine:
    def __init__(self):
        self.left = [0.0] * TOTAL_SAMPLES
        self.right = [0.0] * TOTAL_SAMPLES
        
    def add_note(self, start_t, dur_t, midi_note, osc_type='sine', vol=0.2, pan=0.0, detune=0.0):
        # Wraps around TOTAL_SAMPLES so note releases wrap cleanly into start for 100% seamless loop
        freq1 = midi_to_freq(midi_note)
        freq2 = midi_to_freq(midi_note) * (1.0 + detune)
        
        start_idx = int(start_t * SAMPLE_RATE) % TOTAL_SAMPLES
        note_samples = int(dur_t * SAMPLE_RATE)
        
        # Soft ADSR
        att_len = int(min(0.04 * SAMPLE_RATE, note_samples * 0.2))
        rel_len = int(min(0.12 * SAMPLE_RATE, note_samples * 0.4))
        sus_len = max(0, note_samples - att_len - rel_len)
        
        l_mult = math.cos((pan + 1.0) * math.pi / 4.0) * vol
        r_mult = math.sin((pan + 1.0) * math.pi / 4.0) * vol
        
        phase1 = 0.0
        phase2 = 0.0
        step1 = 2.0 * math.pi * freq1 / SAMPLE_RATE
        step2 = 2.0 * math.pi * freq2 / SAMPLE_RATE
        
        for n in range(note_samples):
            idx = (start_idx + n) % TOTAL_SAMPLES
            
            # Envelope
            if n < att_len:
                env = float(n) / max(1, att_len)
            elif n < att_len + sus_len:
                env = 1.0
            else:
                rel_idx = n - (att_len + sus_len)
                env = max(0.0, 1.0 - float(rel_idx) / max(1, rel_len))
            
            # Oscillators
            if osc_type == 'square':
                sample = 0.5 * (osc_soft_square(phase1) + osc_soft_square(phase2))
            elif osc_type == 'triangle':
                sample = 0.5 * (osc_triangle(phase1) + osc_triangle(phase2))
            elif osc_type == 'warm':
                sample = 0.6 * osc_triangle(phase1) + 0.4 * osc_soft_square(phase2, harmonics=3)
            else:
                sample = 0.5 * (osc_sine(phase1) + osc_sine(phase2))
                
            sample *= env
            self.left[idx] += sample * l_mult
            self.right[idx] += sample * r_mult
            
            phase1 += step1
            phase2 += step2

# 1. NOCTURNE CHIPTUNE
# Chords: Dm9 (4 beats) -> Gm7 (4 beats) -> C9 (4 beats) -> Fmaj7 (4 beats)
def create_nocturne_chiptune():
    synth = SynthEngine()
    chords = [
        # (root_midi, [chord notes])
        (38, [50, 53, 57, 60, 64]), # D2, D3, F3, A3, C4, E4 (Dm9)
        (43, [46, 50, 55, 58, 62]), # G2, Bb2, D3, G3, Bb3, D4 (Gm7)
        (36, [48, 52, 55, 58, 62]), # C2, C3, E3, G3, Bb3, D4 (C9)
        (41, [48, 53, 57, 60, 64]), # F2, C3, F3, A3, C4, E4 (Fmaj7)
    ]
    
    # 4 bars, 4 beats each
    for bar in range(4):
        bar_start = bar * 4 * BEAT_DUR
        bass_note, chord_notes = chords[bar]
        
        # Soft warm bass (playing root and fifth)
        synth.add_note(bar_start, BEAT_DUR * 1.8, bass_note, 'triangle', vol=0.35, pan=0.0)
        synth.add_note(bar_start + BEAT_DUR * 2.0, BEAT_DUR * 1.8, bass_note + 7, 'triangle', vol=0.30, pan=0.0)
        
        # Gentle sustained pad chords
        for cn in chord_notes[:3]:
            synth.add_note(bar_start, BEAT_DUR * 3.8, cn, 'warm', vol=0.12, pan=-0.2, detune=0.003)
        for cn in chord_notes[2:]:
            synth.add_note(bar_start, BEAT_DUR * 3.8, cn, 'warm', vol=0.10, pan=0.2, detune=-0.003)
            
        # Delicate night arpeggios (8th notes)
        arp_pattern = [chord_notes[i % len(chord_notes)] + 12 for i in [0, 2, 3, 4, 3, 2, 4, 1]]
        for step in range(8):
            step_time = bar_start + step * (BEAT_DUR * 0.5)
            note = arp_pattern[step]
            pan = -0.35 if (step % 2 == 0) else 0.35
            synth.add_note(step_time, BEAT_DUR * 0.45, note, 'triangle', vol=0.18, pan=pan)
            
    # Expressive soft lead melody across the 4 bars
    # Bar 1: A4 -> F4 -> G4 -> A4
    synth.add_note(0 * BEAT_DUR, BEAT_DUR * 1.2, 69, 'square', vol=0.20, pan=-0.1)
    synth.add_note(1.5 * BEAT_DUR, BEAT_DUR * 0.9, 65, 'square', vol=0.18, pan=-0.1)
    synth.add_note(2.5 * BEAT_DUR, BEAT_DUR * 0.9, 67, 'square', vol=0.18, pan=0.1)
    synth.add_note(3.5 * BEAT_DUR, BEAT_DUR * 0.9, 69, 'square', vol=0.20, pan=0.1)
    # Bar 2: Bb4 -> D5 -> C5
    synth.add_note(4 * BEAT_DUR, BEAT_DUR * 1.8, 70, 'square', vol=0.22, pan=0.15)
    synth.add_note(6 * BEAT_DUR, BEAT_DUR * 0.9, 74, 'square', vol=0.19, pan=-0.1)
    synth.add_note(7 * BEAT_DUR, BEAT_DUR * 0.9, 72, 'square', vol=0.18, pan=-0.1)
    # Bar 3: G4 -> E4 -> F4 -> G4
    synth.add_note(8 * BEAT_DUR, BEAT_DUR * 1.2, 67, 'square', vol=0.20, pan=-0.1)
    synth.add_note(9.5 * BEAT_DUR, BEAT_DUR * 0.9, 64, 'square', vol=0.18, pan=-0.1)
    synth.add_note(10.5 * BEAT_DUR, BEAT_DUR * 0.9, 65, 'square', vol=0.18, pan=0.1)
    synth.add_note(11.5 * BEAT_DUR, BEAT_DUR * 0.9, 67, 'square', vol=0.20, pan=0.1)
    # Bar 4: A4 -> E5 -> D5 (resolving for loop)
    synth.add_note(12 * BEAT_DUR, BEAT_DUR * 1.8, 69, 'square', vol=0.22, pan=0.0)
    synth.add_note(14 * BEAT_DUR, BEAT_DUR * 0.9, 76, 'square', vol=0.19, pan=0.1)
    synth.add_note(15 * BEAT_DUR, BEAT_DUR * 0.9, 74, 'square', vol=0.18, pan=-0.1)
    
    render_wav("extras/nocturne_chiptune.wav", synth.left, synth.right)

# 2. LAVENDER CHILLWAVE
# Chords: Bbmaj7 -> Am7 -> Gm7 -> Fmaj7 (dreamy descending Catppuccin palette)
def create_lavender_chillwave():
    synth = SynthEngine()
    chords = [
        (46, [58, 62, 65, 69]), # Bb2 bass, Bb3, D4, F4, A4 (Bbmaj7)
        (45, [57, 60, 64, 67]), # A2 bass, A3, C4, E4, G4 (Am7)
        (43, [55, 58, 62, 65]), # G2 bass, G3, Bb3, D4, F4 (Gm7)
        (41, [53, 57, 60, 64]), # F2 bass, F3, A3, C4, E4 (Fmaj7)
    ]
    
    for bar in range(4):
        bar_start = bar * 4 * BEAT_DUR
        bass, notes = chords[bar]
        
        # Chillwave syncopated warm sub bass
        synth.add_note(bar_start, BEAT_DUR * 1.4, bass, 'warm', vol=0.38, pan=0.0, detune=0.002)
        synth.add_note(bar_start + BEAT_DUR * 1.5, BEAT_DUR * 0.8, bass, 'warm', vol=0.32, pan=0.0, detune=0.002)
        synth.add_note(bar_start + BEAT_DUR * 2.5, BEAT_DUR * 1.3, bass + 7, 'warm', vol=0.30, pan=0.0, detune=0.002)
        
        # Soft lush chords on beats 1 and 2.5 (chillwave electric piano pulse)
        for n in notes:
            synth.add_note(bar_start, BEAT_DUR * 1.2, n, 'warm', vol=0.14, pan=-0.25, detune=0.004)
            synth.add_note(bar_start + BEAT_DUR * 1.5, BEAT_DUR * 1.0, n, 'warm', vol=0.12, pan=0.25, detune=-0.004)
            synth.add_note(bar_start + BEAT_DUR * 3.0, BEAT_DUR * 0.8, n, 'warm', vol=0.10, pan=0.0, detune=0.002)
            
        # Subtle gentle high-register bells (Lavender twinkle)
        twinkle = notes[-1] + 12
        synth.add_note(bar_start + BEAT_DUR * 0.5, BEAT_DUR * 0.6, twinkle, 'sine', vol=0.12, pan=0.4)
        synth.add_note(bar_start + BEAT_DUR * 2.0, BEAT_DUR * 0.6, twinkle + 2, 'sine', vol=0.12, pan=-0.4)
        synth.add_note(bar_start + BEAT_DUR * 3.5, BEAT_DUR * 0.6, twinkle - 2, 'sine', vol=0.10, pan=0.2)
        
    # Melodic motif: cozy and relaxing
    synth.add_note(0 * BEAT_DUR, BEAT_DUR * 2.0, 72, 'triangle', vol=0.22, pan=-0.1) # C5
    synth.add_note(2.5 * BEAT_DUR, BEAT_DUR * 1.2, 69, 'triangle', vol=0.20, pan=0.1) # A4
    synth.add_note(4 * BEAT_DUR, BEAT_DUR * 2.0, 70, 'triangle', vol=0.22, pan=-0.1) # Bb4
    synth.add_note(6.5 * BEAT_DUR, BEAT_DUR * 1.2, 67, 'triangle', vol=0.20, pan=0.1) # G4
    synth.add_note(8 * BEAT_DUR, BEAT_DUR * 2.0, 69, 'triangle', vol=0.22, pan=-0.1) # A4
    synth.add_note(10.5 * BEAT_DUR, BEAT_DUR * 1.2, 65, 'triangle', vol=0.20, pan=0.1) # F4
    synth.add_note(12 * BEAT_DUR, BEAT_DUR * 2.0, 67, 'triangle', vol=0.22, pan=0.0) # G4
    synth.add_note(14.5 * BEAT_DUR, BEAT_DUR * 1.3, 64, 'triangle', vol=0.18, pan=0.0) # E4
    
    render_wav("extras/lavender_chillwave.wav", synth.left, synth.right)

# 3. DREAMY DUSK
# Style: Ethereal ambient pad swells with delicate celesta arpeggios
def create_dreamy_dusk():
    synth = SynthEngine()
    chords = [
        (41, [53, 57, 60, 64, 69]), # F2, F3, A3, C4, E4, A4 (Fmaj7)
        (40, [52, 55, 59, 64, 67]), # E2, E3, G3, B3, E4, G4 (Em7)
        (38, [50, 53, 57, 62, 65]), # D2, D3, F3, A3, D4, F4 (Dm7)
        (33, [45, 52, 57, 60, 64]), # A1, A2, E3, A3, C4, E4 (Am)
    ]
    
    for bar in range(4):
        bar_start = bar * 4 * BEAT_DUR
        bass, notes = chords[bar]
        
        # Deep round sustained bass
        synth.add_note(bar_start, BEAT_DUR * 3.9, bass, 'triangle', vol=0.36, pan=0.0)
        
        # Ambient drone pads with slow attack and release
        for n in notes:
            synth.add_note(bar_start, BEAT_DUR * 3.9, n, 'sine', vol=0.14, pan=-0.3, detune=0.002)
            synth.add_note(bar_start, BEAT_DUR * 3.9, n + 7, 'sine', vol=0.08, pan=0.3, detune=-0.002)
            
        # Cascading music-box / celesta chimes (16th note triplets / slow rain feel)
        chimes = [notes[1] + 24, notes[2] + 24, notes[3] + 24, notes[4] + 24]
        for step in range(8):
            step_time = bar_start + step * (BEAT_DUR * 0.5)
            note = chimes[step % len(chimes)]
            pan = (step % 4 - 1.5) * 0.4
            synth.add_note(step_time, BEAT_DUR * 0.8, note, 'sine', vol=0.15, pan=pan)
            
    render_wav("extras/dreamy_dusk.wav", synth.left, synth.right)

# 4. SUBTLE PULSE
# Style: Minimalist shadow groove that stays out of the way of arcade SFX
def create_subtle_pulse():
    synth = SynthEngine()
    # Dm -> Bb -> F -> C
    progression = [
        (38, 50, [53, 57, 62]), # D2 bass, D3, [F3, A3, D4]
        (46, 46, [53, 58, 62]), # Bb2 bass, Bb2, [F3, Bb3, D4]
        (41, 53, [57, 60, 65]), # F2 bass, F3, [A3, C4, F4]
        (36, 48, [55, 60, 64]), # C2 bass, C3, [G3, C4, E4]
    ]
    
    for bar in range(4):
        bar_start = bar * 4 * BEAT_DUR
        bass, root3, chord_notes = progression[bar]
        
        # Minimalist walking rhythmic bass
        for beat in range(4):
            b_time = bar_start + beat * BEAT_DUR
            note = bass if beat in [0, 2] else bass + 7
            synth.add_note(b_time, BEAT_DUR * 0.7, note, 'triangle', vol=0.34, pan=0.0)
            
        # Muted marimba-like chord pulse on off-beats (beats 1.5, 2.5, 3.5)
        for off in [0.5, 1.5, 2.5, 3.5]:
            p_time = bar_start + off * BEAT_DUR
            for cn in chord_notes:
                synth.add_note(p_time, BEAT_DUR * 0.35, cn, 'warm', vol=0.10, pan=0.2 if off < 2 else -0.2)
                
        # Subtle atmospheric shimmer
        synth.add_note(bar_start, BEAT_DUR * 3.8, root3 + 12, 'sine', vol=0.08, pan=0.0, detune=0.001)
        
    render_wav("extras/subtle_pulse.wav", synth.left, synth.right)

if __name__ == '__main__':
    create_nocturne_chiptune()
    create_lavender_chillwave()
    create_dreamy_dusk()
    create_subtle_pulse()
    print("All 4 music samples generated successfully!")
