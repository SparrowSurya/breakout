import wave
import math
import struct
import os

SAMPLE_RATE = 44100

def render_wav_mono(filename, buf, max_amp=0.85):
    peak = max(abs(s) for s in buf) if len(buf) > 0 else 0
    gain = (max_amp / peak) if peak > 0 else 1.0
    
    with wave.open(filename, 'wb') as wf:
        wf.setnchannels(1)
        wf.setsampwidth(2)
        wf.setframerate(SAMPLE_RATE)
        frames = bytearray()
        for s in buf:
            val = int(max(-1.0, min(1.0, s * gain)) * 32767.0)
            frames.extend(struct.pack('<h', val))
        wf.writeframes(frames)
    dur = len(buf) / float(SAMPLE_RATE)
    print(f"Generated {filename} ({dur:.3f}s)")

def generate_disabled_sound(filename):
    # Soft, muted low-register rejection tap/dull thud (conveys 'disabled/denied')
    # Duration ~0.14s: two rapid damped low pulses (a micro 'double-thud' like a gentle knock on wood/slate)
    dur = 0.14
    total_samples = int(SAMPLE_RATE * dur)
    buf = [0.0] * total_samples
    
    # Pulse 1 at t=0.0s, Pulse 2 at t=0.045s
    pulses = [
        (0.00, 180.0, 110.0, 0.05), # start_t, start_f, end_f, pulse_dur
        (0.045, 150.0, 85.0, 0.08)  # second lower 'thud'
    ]
    
    for (st, f_start, f_end, p_dur) in pulses:
        st_idx = int(st * SAMPLE_RATE)
        p_samples = int(p_dur * SAMPLE_RATE)
        phase = 0.0
        for n in range(p_samples):
            idx = st_idx + n
            if idx >= total_samples:
                break
            t_p = n / float(SAMPLE_RATE)
            prog = t_p / p_dur
            freq = f_start + (f_end - f_start) * prog
            phase += 2.0 * math.pi * freq / SAMPLE_RATE
            
            # Smooth attack (fast 3ms) and exponential decay
            att = min(1.0, t_p / 0.004)
            decay = math.exp(-t_p * 60.0)
            env = att * decay
            
            # Warm rounded waveform (triangle body + subtle damped square harmonic)
            tri = math.sin(phase) - (1.0/9.0) * math.sin(3.0 * phase)
            sq = math.sin(phase) + 0.3 * math.sin(3.0 * phase)
            s = 0.75 * tri + 0.25 * sq
            
            buf[idx] += s * env * 0.85

    render_wav_mono(filename, buf)

if __name__ == '__main__':
    target_dir = "extras/sounds"
    os.makedirs(target_dir, exist_ok=True)
    
    out1 = os.path.join(target_dir, "ui_denied.wav")
    out2 = os.path.join(target_dir, "ui_disabled.wav")
    
    generate_disabled_sound(out1)
    
    import shutil
    shutil.copyfile(out1, out2)
    print("Done generating disabled UI sounds!")
