import wave
import math
import struct
import os
import random

SAMPLE_RATE = 44100

def midi_to_freq(m):
    return 440.0 * (2.0 ** ((m - 69) / 12.0))

def osc_soft_square(phase, harmonics=5):
    # Bandlimited warm rounded square wave
    val = 0.0
    for h in range(1, harmonics + 1, 2):
        val += math.sin(h * phase) / (h ** 1.35)
    return val * 0.7

def osc_triangle(phase):
    # Pure smooth triangle wave
    val = 0.0
    for h in range(1, 9, 2):
        sign = -1.0 if ((h - 1) // 2) % 2 else 1.0
        val += sign * math.sin(h * phase) / (h * h)
    return val * 0.8

def osc_sine(phase):
    return math.sin(phase)

def render_wav_stereo(filename, left_buf, right_buf, total_samples, max_amp=0.88):
    peak = 0.0
    for i in range(total_samples):
        al = abs(left_buf[i])
        ar = abs(right_buf[i])
        if al > peak: peak = al
        if ar > peak: peak = ar
    gain = (max_amp / peak) if peak > 0 else 1.0
    
    with wave.open(filename, 'wb') as wf:
        wf.setnchannels(2)
        wf.setsampwidth(2)
        wf.setframerate(SAMPLE_RATE)
        frames = bytearray()
        for i in range(total_samples):
            l = int(max(-1.0, min(1.0, left_buf[i] * gain)) * 32767.0)
            r = int(max(-1.0, min(1.0, right_buf[i] * gain)) * 32767.0)
            frames.extend(struct.pack('<hh', l, r))
        wf.writeframes(frames)
    dur = total_samples / float(SAMPLE_RATE)
    print(f"Generated {filename} ({dur:.2f}s, {total_samples} samples, stereo)")

def render_wav_mono(filename, buf, total_samples, max_amp=0.88):
    peak = max(abs(s) for s in buf) if total_samples > 0 else 0
    gain = (max_amp / peak) if peak > 0 else 1.0
    
    with wave.open(filename, 'wb') as wf:
        wf.setnchannels(1)
        wf.setsampwidth(2)
        wf.setframerate(SAMPLE_RATE)
        frames = bytearray()
        for i in range(total_samples):
            val = int(max(-1.0, min(1.0, buf[i] * gain)) * 32767.0)
            frames.extend(struct.pack('<h', val))
        wf.writeframes(frames)
    dur = total_samples / float(SAMPLE_RATE)
    print(f"Generated {filename} ({dur:.2f}s, mono)")

# ============================================================================
# PART 1: 2-MINUTE LOOPING BACKGROUND MUSIC (LAVENDER CHILLWAVE)
# ============================================================================
def generate_lavender_chillwave_2min(output_path):
    print("Synthesizing 2-minute seamless Lavender Chillwave...")
    BPM = 96.0
    BEAT_DUR = 60.0 / BPM  # 0.625s per beat
    BAR_DUR = BEAT_DUR * 4.0  # 2.5s per bar
    TOTAL_BARS = 48  # 48 bars * 2.5s = 120.0s (exactly 2 minutes)
    TOTAL_SAMPLES = int(SAMPLE_RATE * (TOTAL_BARS * BAR_DUR))
    
    left = [0.0] * TOTAL_SAMPLES
    right = [0.0] * TOTAL_SAMPLES
    
    def add_note(start_t, dur_t, midi, osc_type='warm', vol=0.2, pan=0.0, detune=0.003, att_ratio=0.1, rel_ratio=0.4):
        freq1 = midi_to_freq(midi)
        freq2 = midi_to_freq(midi) * (1.0 + detune)
        
        start_idx = int(start_t * SAMPLE_RATE) % TOTAL_SAMPLES
        note_samples = int(dur_t * SAMPLE_RATE)
        
        att_len = int(note_samples * att_ratio)
        rel_len = int(note_samples * rel_ratio)
        sus_len = max(0, note_samples - att_len - rel_len)
        
        l_mult = math.cos((pan + 1.0) * math.pi / 4.0) * vol
        r_mult = math.sin((pan + 1.0) * math.pi / 4.0) * vol
        
        phase1 = 0.0
        phase2 = 0.0
        step1 = 2.0 * math.pi * freq1 / SAMPLE_RATE
        step2 = 2.0 * math.pi * freq2 / SAMPLE_RATE
        
        for n in range(note_samples):
            idx = (start_idx + n) % TOTAL_SAMPLES
            if n < att_len:
                env = float(n) / max(1, att_len)
            elif n < att_len + sus_len:
                env = 1.0
            else:
                rel_idx = n - (att_len + sus_len)
                env = max(0.0, 1.0 - float(rel_idx) / max(1, rel_len))
                
            if osc_type == 'warm':
                s = 0.6 * osc_triangle(phase1) + 0.4 * osc_soft_square(phase2, harmonics=3)
            elif osc_type == 'triangle':
                s = 0.5 * (osc_triangle(phase1) + osc_triangle(phase2))
            elif osc_type == 'sine':
                s = 0.5 * (osc_sine(phase1) + osc_sine(phase2))
            elif osc_type == 'bell':
                s = 0.7 * osc_sine(phase1) + 0.3 * osc_sine(phase1 * 2.76)
            else:
                s = 0.5 * (osc_soft_square(phase1) + osc_soft_square(phase2))
                
            s *= env
            left[idx] += s * l_mult
            right[idx] += s * r_mult
            
            phase1 += step1
            phase2 += step2

    # Chord progressions for the 4 sections
    # Section 1 & 4 (Iconic Lavender): Bbmaj7 -> Am7 -> Gm7 -> Fmaj7
    prog_lavender = [
        (46, [58, 62, 65, 69]), # Bb2 bass, [Bb3, D4, F4, A4]
        (45, [57, 60, 64, 67]), # A2 bass,  [A3, C4, E4, G4]
        (43, [55, 58, 62, 65]), # G2 bass,  [G3, Bb3, D4, F4]
        (41, [53, 57, 60, 64]), # F2 bass,  [F3, A3, C4, E4]
    ]
    
    # Section 2 (Warm Dusk Bloom): Gm7 -> C9 -> Fmaj7 -> Dm9
    prog_bloom = [
        (43, [55, 58, 62, 65]), # G2 bass,  [G3, Bb3, D4, F4]
        (36, [48, 52, 55, 58, 62]), # C2 bass,  [C3, E3, G3, Bb3, D4]
        (41, [53, 57, 60, 64]), # F2 bass,  [F3, A3, C4, E4]
        (38, [50, 53, 57, 60, 64]), # D2 bass,  [D3, F3, A3, C4, E4]
    ]
    
    # Section 3 (Deep Shadow Velvet): Ebmaj7 -> Dm7 -> Gm9 -> Fmaj7
    prog_shadow = [
        (39, [51, 55, 58, 62]), # Eb2 bass, [Eb3, G3, Bb3, D4]
        (38, [50, 53, 57, 60]), # D2 bass,  [D3, F3, A3, C4]
        (43, [55, 58, 62, 65, 69]), # G2 bass,  [G3, Bb3, D4, F4, A4]
        (41, [53, 57, 60, 64]), # F2 bass,  [F3, A3, C4, E4]
    ]
    
    for bar in range(TOTAL_BARS):
        bar_start = bar * BAR_DUR
        
        # Determine section
        if bar < 16:
            prog = prog_lavender
            sec = 1
        elif bar < 28:
            prog = prog_bloom
            sec = 2
        elif bar < 40:
            prog = prog_shadow
            sec = 3
        else:
            prog = prog_lavender
            sec = 4
            
        bass, chord_notes = prog[bar % 4]
        
        # 1. Warm syncopated bassline
        synth_type = 'warm' if sec in [1, 4] else 'triangle'
        add_note(bar_start, BEAT_DUR * 1.3, bass, synth_type, vol=0.36, pan=0.0)
        add_note(bar_start + BEAT_DUR * 1.5, BEAT_DUR * 0.8, bass, synth_type, vol=0.30, pan=0.0)
        add_note(bar_start + BEAT_DUR * 2.5, BEAT_DUR * 1.3, bass + 7, synth_type, vol=0.28, pan=0.0)
        
        # 2. Electric piano / chord pad pulses
        vol_pad = 0.12 if bar < 44 else 0.08
        for n in chord_notes:
            add_note(bar_start, BEAT_DUR * 1.3, n, 'warm', vol=vol_pad, pan=-0.25, detune=0.003)
            add_note(bar_start + BEAT_DUR * 1.5, BEAT_DUR * 0.9, n, 'warm', vol=vol_pad * 0.9, pan=0.25, detune=-0.003)
            add_note(bar_start + BEAT_DUR * 3.0, BEAT_DUR * 0.8, n, 'warm', vol=vol_pad * 0.8, pan=0.0, detune=0.002)
            
        # 3. Ambient bell twinkles (Lavender rain)
        twinkle = chord_notes[-1] + 12
        add_note(bar_start + BEAT_DUR * 0.5, BEAT_DUR * 0.7, twinkle, 'bell', vol=0.10, pan=0.35)
        add_note(bar_start + BEAT_DUR * 2.0, BEAT_DUR * 0.7, twinkle + 2, 'bell', vol=0.10, pan=-0.35)
        add_note(bar_start + BEAT_DUR * 3.5, BEAT_DUR * 0.7, twinkle - 2, 'bell', vol=0.08, pan=0.15)
        
        # 4. Melodic themes spanning across bars
        # Section 1 melody (Bars 0-15)
        if sec == 1:
            motif_m = [72, 69, 70, 67, 69, 65, 67, 64][(bar % 8)]
            add_note(bar_start, BEAT_DUR * 2.0, motif_m, 'triangle', vol=0.18, pan=-0.1)
            add_note(bar_start + BEAT_DUR * 2.5, BEAT_DUR * 1.2, motif_m - 3, 'triangle', vol=0.15, pan=0.1)
        # Section 2 melody (Bars 16-27): Expressive Dusk Lead
        elif sec == 2:
            m_notes = [74, 72, 69, 70, 67, 65, 64, 62][(bar % 8)]
            add_note(bar_start + BEAT_DUR * 0.5, BEAT_DUR * 1.4, m_notes, 'warm', vol=0.18, pan=0.15)
            add_note(bar_start + BEAT_DUR * 2.0, BEAT_DUR * 1.8, m_notes + 3, 'warm', vol=0.20, pan=-0.15)
        # Section 3 melody (Bars 28-39): Deep Shadow Chimes
        elif sec == 3:
            for s in [0, 1, 2, 3]:
                cn = chord_notes[s % len(chord_notes)] + 12
                add_note(bar_start + s * BEAT_DUR, BEAT_DUR * 0.9, cn, 'bell', vol=0.12, pan=(s - 1.5) * 0.3)
        # Section 4: Gentle outro resolution into Bar 0
        elif sec == 4:
            if bar < 46:
                motif_m = [72, 69, 70, 67][bar % 4]
                add_note(bar_start, BEAT_DUR * 2.5, motif_m, 'triangle', vol=0.15, pan=0.0)

    render_wav_stereo(output_path, left, right, TOTAL_SAMPLES, max_amp=0.85)

# ============================================================================
# PART 2: UI SOUNDS
# ============================================================================
def generate_ui_sounds(sounds_dir):
    # 1. UI Mouse Click: Tactile, soft wooden-switch/felt pop
    dur = 0.075
    samples = int(SAMPLE_RATE * dur)
    buf = [0.0] * samples
    phase = 0.0
    for i in range(samples):
        t = i / float(SAMPLE_RATE)
        env = math.exp(-t * 85.0)
        # Pitch slides smoothly from 520 Hz down to 220 Hz
        freq = 520.0 - 300.0 * (t / dur)
        step = 2.0 * math.pi * freq / SAMPLE_RATE
        phase += step
        # Layer soft sine and triangle with a tiny transient click
        s = 0.7 * math.sin(phase) + 0.3 * osc_triangle(phase)
        if i < 40:
            s += 0.25 * (1.0 - i / 40.0)
        buf[i] = s * env
    render_wav_mono(os.path.join(sounds_dir, "ui_click.wav"), buf, samples)
    
    # 2. UI Focus: Soft lavender bell blip / droplet harmonic (C6 1046 Hz)
    dur = 0.12
    samples = int(SAMPLE_RATE * dur)
    buf = [0.0] * samples
    f1 = 1046.5 # C6
    f2 = 2093.0 # C7 (soft octave shimmer)
    phase1 = phase2 = 0.0
    s1 = 2.0 * math.pi * f1 / SAMPLE_RATE
    s2 = 2.0 * math.pi * f2 / SAMPLE_RATE
    for i in range(samples):
        t = i / float(SAMPLE_RATE)
        # Smooth attack, exponential release
        att = min(1.0, t / 0.012)
        rel = math.exp(-t * 28.0)
        env = att * rel
        phase1 += s1
        phase2 += s2
        s = 0.75 * math.sin(phase1) + 0.25 * math.sin(phase2)
        buf[i] = s * env
    render_wav_mono(os.path.join(sounds_dir, "ui_focus.wav"), buf, samples)

# ============================================================================
# PART 3: GAMEPLAY SFX (MATCHING assets/sounds/ WITH CHILLWAVE VIBE)
# ============================================================================
def generate_game_sfx(sounds_dir):
    # 1. Ball-Hit-Paddle: Warm, punchy elastic bounce with low-end resonance
    dur = 0.14
    samples = int(SAMPLE_RATE * dur)
    buf = [0.0] * samples
    phase = 0.0
    phase_sub = 0.0
    for i in range(samples):
        t = i / float(SAMPLE_RATE)
        env = math.exp(-t * 32.0)
        # Frequency sweep from 360 Hz down to 160 Hz
        f = 360.0 - 200.0 * math.sqrt(t / dur)
        step = 2.0 * math.pi * f / SAMPLE_RATE
        phase += step
        # Sub-body at 90 Hz
        phase_sub += 2.0 * math.pi * 90.0 / SAMPLE_RATE
        s = 0.65 * math.sin(phase) + 0.35 * osc_triangle(phase_sub)
        buf[i] = s * env
    render_wav_mono(os.path.join(sounds_dir, "Ball-Hit-Paddle.wav"), buf, samples)

    # 2. Ball-Hit-Wall: Crisp, rounded boundary tap
    dur = 0.09
    samples = int(SAMPLE_RATE * dur)
    buf = [0.0] * samples
    phase = 0.0
    for i in range(samples):
        t = i / float(SAMPLE_RATE)
        env = math.exp(-t * 55.0)
        # 440 Hz (A4) quick decay tap
        f = 440.0 - 120.0 * (t / dur)
        step = 2.0 * math.pi * f / SAMPLE_RATE
        phase += step
        s = 0.8 * osc_triangle(phase) + 0.2 * osc_soft_square(phase, harmonics=3)
        buf[i] = s * env
    render_wav_mono(os.path.join(sounds_dir, "Ball-Hit-Wall.wav"), buf, samples)

    # 3. Ball-Hit-Tile: Melodic glass/marimba chime pop (F5 698.4 Hz + C6 1046.5 Hz)
    dur = 0.16
    samples = int(SAMPLE_RATE * dur)
    buf = [0.0] * samples
    f1 = 698.46 # F5
    f2 = 1046.50 # C6
    p1 = p2 = 0.0
    s1 = 2.0 * math.pi * f1 / SAMPLE_RATE
    s2 = 2.0 * math.pi * f2 / SAMPLE_RATE
    for i in range(samples):
        t = i / float(SAMPLE_RATE)
        env = math.exp(-t * 22.0)
        p1 += s1
        p2 += s2
        s = 0.65 * math.sin(p1) + 0.35 * math.sin(p2)
        buf[i] = s * env
    render_wav_mono(os.path.join(sounds_dir, "Ball-Hit-Tile.wav"), buf, samples)

    # 4. Ball-Hit-Metal-Tile: Heavy, solid metallic resonance without harshness
    dur = 0.26
    samples = int(SAMPLE_RATE * dur)
    buf = [0.0] * samples
    # Inharmonic metallic partials: 380 Hz, 620 Hz, 940 Hz
    p1 = p2 = p3 = 0.0
    s1 = 2.0 * math.pi * 380.0 / SAMPLE_RATE
    s2 = 2.0 * math.pi * 620.0 / SAMPLE_RATE
    s3 = 2.0 * math.pi * 940.0 / SAMPLE_RATE
    for i in range(samples):
        t = i / float(SAMPLE_RATE)
        env = math.exp(-t * 16.0)
        p1 += s1
        p2 += s2
        p3 += s3
        s = 0.5 * osc_triangle(p1) + 0.3 * math.sin(p2) + 0.2 * math.sin(p3)
        buf[i] = s * env
    render_wav_mono(os.path.join(sounds_dir, "Ball-Hit-Metal-Tile.wav"), buf, samples)

    # 5. Tile-Destroy: Satisfying soft shattering poof & descending chime burst
    dur = 0.32
    samples = int(SAMPLE_RATE * dur)
    buf = [0.0] * samples
    # Rapid warm arpeggio: A5 (880) -> F5 (698) -> D5 (587)
    notes = [880.0, 698.46, 587.33, 440.0]
    for i in range(samples):
        t = i / float(SAMPLE_RATE)
        step_idx = min(len(notes) - 1, int(t / 0.06))
        freq = notes[step_idx]
        env = math.exp(- (t - step_idx * 0.06) * 20.0) * math.exp(-t * 6.0)
        phase = 2.0 * math.pi * freq * t
        s = 0.6 * math.sin(phase) + 0.4 * osc_triangle(phase)
        # Soft filtered noise texture
        noise = (random.random() * 2.0 - 1.0) * math.exp(-t * 30.0) * 0.15
        buf[i] = s * env + noise
    render_wav_mono(os.path.join(sounds_dir, "Tile-Destroy.wav"), buf, samples)

    # 6. Countdown: Gentle, polite radar pulse (880 Hz + 1320 Hz)
    dur = 0.22
    samples = int(SAMPLE_RATE * dur)
    buf = [0.0] * samples
    p1 = p2 = 0.0
    s1 = 2.0 * math.pi * 880.0 / SAMPLE_RATE
    s2 = 2.0 * math.pi * 1320.0 / SAMPLE_RATE
    for i in range(samples):
        t = i / float(SAMPLE_RATE)
        att = min(1.0, t / 0.02)
        rel = math.exp(-t * 14.0)
        env = att * rel
        p1 += s1
        p2 += s2
        s = 0.7 * math.sin(p1) + 0.3 * math.sin(p2)
        buf[i] = s * env
    render_wav_mono(os.path.join(sounds_dir, "Countdown.wav"), buf, samples)

    # 7. Countdown-Go: Uplifting launch chord (F5 -> A5 -> C6)
    dur = 0.55
    samples = int(SAMPLE_RATE * dur)
    buf = [0.0] * samples
    tones = [698.46, 880.0, 1046.50]
    for i in range(samples):
        t = i / float(SAMPLE_RATE)
        s = 0.0
        for idx, freq in enumerate(tones):
            t_offset = max(0.0, t - idx * 0.05)
            att = min(1.0, t_offset / 0.02) if t >= idx * 0.05 else 0.0
            env = att * math.exp(-t_offset * 7.0)
            phase = 2.0 * math.pi * freq * t
            s += (0.6 * math.sin(phase) + 0.4 * osc_triangle(phase)) * env
        buf[i] = s * 0.45
    render_wav_mono(os.path.join(sounds_dir, "Countdown-Go.wav"), buf, samples)

    # 8. Life-Lost: Gentle descending sad chiptune lament (D5 -> Bb4 -> G4 -> E4)
    dur = 0.95
    samples = int(SAMPLE_RATE * dur)
    buf = [0.0] * samples
    l_notes = [587.33, 466.16, 392.00, 329.63]
    for i in range(samples):
        t = i / float(SAMPLE_RATE)
        step_idx = min(len(l_notes) - 1, int(t / 0.22))
        freq = l_notes[step_idx]
        t_sub = t - step_idx * 0.22
        env = math.exp(-t_sub * 7.0) * (1.0 - t / dur)
        # Gentle vibrato
        vibrato = math.sin(2.0 * math.pi * 5.5 * t) * 3.5
        phase = 2.0 * math.pi * (freq + vibrato) * t
        s = 0.7 * osc_triangle(phase) + 0.3 * math.sin(phase)
        buf[i] = s * env
    render_wav_mono(os.path.join(sounds_dir, "Life-Lost.wav"), buf, samples)

    # 9. Game-Lost: Melancholic, nostalgic dusk resolution chord phrase (Dm -> Gm -> A -> Dm)
    dur = 2.1
    samples = int(SAMPLE_RATE * dur)
    buf = [0.0] * samples
    chords = [
        [293.66, 349.23, 440.0],  # Dm (D4, F4, A4)
        [261.63, 311.13, 392.0],  # C/Gm (C4, Eb4, G4)
        [220.00, 277.18, 329.63], # A (A3, C#4, E4)
        [146.83, 293.66, 349.23], # Low Dm (D3, D4, F4)
    ]
    chord_dur = dur / 4.0
    for i in range(samples):
        t = i / float(SAMPLE_RATE)
        c_idx = min(len(chords) - 1, int(t / chord_dur))
        t_c = t - c_idx * chord_dur
        env = math.exp(-t_c * 2.8) * (1.0 - (t / dur) * 0.4)
        s = 0.0
        for freq in chords[c_idx]:
            phase = 2.0 * math.pi * freq * t
            s += 0.5 * osc_triangle(phase) + 0.5 * math.sin(phase)
        buf[i] = (s / len(chords[c_idx])) * env
    render_wav_mono(os.path.join(sounds_dir, "Game-Lost.wav"), buf, samples)

    # 10. Game-Won: Warm retro victory fanfare (Bbmaj7 -> C -> Fmaj7)
    dur = 2.4
    samples = int(SAMPLE_RATE * dur)
    buf = [0.0] * samples
    fanfare = [
        (0.00, 0.40, [466.16, 587.33, 698.46, 880.00]), # Bbmaj7 (Bb4, D5, F5, A5)
        (0.45, 0.40, [523.25, 659.25, 783.99]),         # C (C5, E5, G5)
        (0.90, 1.45, [698.46, 880.00, 1046.50, 1318.51]) # Fmaj7 triumph (F5, A5, C6, E6)
    ]
    for i in range(samples):
        t = i / float(SAMPLE_RATE)
        s = 0.0
        for (st, ch_dur, chord) in fanfare:
            if t >= st:
                t_sub = t - st
                if t_sub < ch_dur:
                    att = min(1.0, t_sub / 0.03)
                    rel = math.exp(-t_sub * (3.0 if st < 0.8 else 1.6))
                    env = att * rel
                    for freq in chord:
                        phase = 2.0 * math.pi * freq * t
                        s += (0.6 * math.sin(phase) + 0.4 * osc_triangle(phase)) * env
        buf[i] = s * 0.28
    render_wav_mono(os.path.join(sounds_dir, "Game-Won.wav"), buf, samples)

    # 11. Stage-Finished: Sparkling 5-note rising arpeggio ending on held chord
    dur = 1.5
    samples = int(SAMPLE_RATE * dur)
    buf = [0.0] * samples
    arp = [
        (0.00, 698.46),  # F5
        (0.10, 880.00),  # A5
        (0.20, 1046.50), # C6
        (0.30, 1174.66), # D6
        (0.40, 1396.91), # F6
    ]
    # Held resolving chord at 0.5s: F5, A5, C6, E6
    chord_held = [698.46, 880.00, 1046.50, 1318.51]
    for i in range(samples):
        t = i / float(SAMPLE_RATE)
        s = 0.0
        for (st, freq) in arp:
            if t >= st:
                t_sub = t - st
                env = math.exp(-t_sub * 10.0)
                phase = 2.0 * math.pi * freq * t
                s += (0.7 * math.sin(phase) + 0.3 * osc_triangle(phase)) * env
        if t >= 0.5:
            t_sub = t - 0.5
            env = math.exp(-t_sub * 2.8) * 0.5
            for freq in chord_held:
                phase = 2.0 * math.pi * freq * t
                s += (0.6 * math.sin(phase) + 0.4 * osc_triangle(phase)) * env
        buf[i] = s * 0.38
    render_wav_mono(os.path.join(sounds_dir, "Stage-Finished.wav"), buf, samples)

if __name__ == '__main__':
    target_dir = "extras/sounds"
    os.makedirs(target_dir, exist_ok=True)
    
    # 1. 2-minute looping background music
    bgm_path = os.path.join(target_dir, "lavender_chillwave_2min.wav")
    generate_lavender_chillwave_2min(bgm_path)
    
    # Also save as lavender_chillwave.wav in extras/sounds
    import shutil
    shutil.copyfile(bgm_path, os.path.join(target_dir, "lavender_chillwave.wav"))
    
    # 2. UI sounds
    generate_ui_sounds(target_dir)
    
    # 3. Game SFX
    generate_game_sfx(target_dir)
    
    print("\nAll sounds created successfully in extras/sounds/!")
