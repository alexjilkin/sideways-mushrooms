# Sonic Pi 
use_bpm 60
 
@input_name = "/midi:teensy_midi_teensy_midi_midi_1_20_0:1"
@is_kick_on = false
@is_snare_on = false
@is_hihat_on = false
@effect_value = 0
 
@is_drums_on = false
 
@m = [:A2, :C2, :A2, :D2, :C2, :A2, :A2, :D2].ring
@current_chord
with_fx :wobble, phase: 2, mix: 0  do |wobble|
  define :get_triggered_instrument do
    use_real_time
 
    note, velocity = sync @input_name + "/note_on"
 
    # Trumpet
    if (note == 10 && velocity > 20)
      return :bell_trigger, velocity * 1.2
    end
 
    # Wave
    if (note == 3 && velocity > 20)
      return :bell2_trigger, velocity * 1.4
    end
    #Mushroom
    if (note == 2 && velocity > 18)
      return :chords_trigger, velocity * 3
    end
 
    #Cube
    if (note == 5 && velocity > 65 && velocity != 127)
      return :arpeggio_trigger, velocity
    end
 
    if (note == 46)
      @arpeggio_volume = velocity
    end
    if (note == 37)
      @is_snare_on = true
    end
    if (note == 38)
      @is_hihat_on = true
    end
  end
 
  define :control_instrument do
    control, value = sync @input_name + "/control_change"
    #Cube
    if (control == 10)
      control wobble, mix: value / 240.0
    end
  end
  define :get_off_instrument do
    use_real_time
    note, velocity = sync @input_name + "/note_off"
    if (note == 36)
      @is_drums_on = false
    end
  end
 
  live_loop :chords do
    use_synth :blade
    use_synth_defaults attack: 0.3, cutoff: rrand(70, 110), sustein: 1.5 , release: rrand(0.7, 1.7), amp: 0.8
    triggered_instrument, velocity = get_triggered_instrument
    if (triggered_instrument == :chords_trigger)
      with_fx :gverb, mix: 0.4, spread: 0.8, damp: 0.8 do
        with_fx :flanger do
          sync :quarter
          play_chord chord(@current_chord, :major), amp: velocity / 128.0
        end
      end
 
    end
 
  end
 
  live_loop :bell do
    use_real_time
 
    triggered_instrument, velocity = get_triggered_instrument
    if (triggered_instrument == :bell_trigger)
 
      use_synth :pretty_bell
 
 
      use_synth_defaults attack: rrand(0.05, 0.1), cutoff: rrand(70, 110), release: rrand(1, 2), amp: velocity/128.0
      with_fx :echo, mix: 0.3, spread: 0.6, damp: 0.8 do
        sync :smallest
        play chord(@current_chord, :sus2).tick
      end
    end
  end
 
  live_loop :bell2 do
    use_real_time
 
    triggered_instrument, velocity = get_triggered_instrument
    if (triggered_instrument == :bell2_trigger)
 
      use_synth :chipbass
 
      use_synth_defaults attack: rrand(0.05, 0.1), cutoff: rrand(70, 110), release: rrand(1, 2), amp: velocity/128.0
      with_fx :echo, mix: 0.3, spread: 0.6, damp: 0.8 do
        sync :smallest
        play chord(@current_chord, :sus2).tick
      end
    end
  end
 
  live_loop :allways_on_bell do
    use_synth :pretty_bell
    use_synth_defaults cutoff: rrand(70, 110), release: rrand(1, 2), amp: 0.8
    with_fx :echo, mix: 0.1, spread: 0.8, damp: 0.8 do
      with_fx :lpf, cutoff: 50 do
        sync :two
        play @current_chord
      end
    end
  end
  live_loop :snare do
    with_fx :lpf, cutoff: 75, amp: 0.8 do |sk|
      with_fx :reverb, mix: 0.4, spread: 0.2, damp: 0.3, amp: 0.7 do |s|
        sync :three
 
        sample :tabla_te2 , amp: 1
      end
    end
  end
 
  live_loop :snareEnding do
    with_fx :lpf, cutoff: 75, amp: 0.6 do |sk|
      with_fx :reverb, mix: 0.4, spread: 0.2, damp: 0.5, amp: 0.8 do |s|
        sync :fourth
        sync :four
        sync :mi
 
        sample :tabla_ke2 , amp: 0.7
        sleep 0.125
        sample :tabla_ke2 , amp: 0.7
        sleep 0.125
      end
    end
  end
 
  live_loop :kick do
    with_fx :lpf, cutoff: 60, amp: 1  do |k|
      sync :one
      sample :bd_ada, amp: 1
      sync :four
      sync :mi
      sample :bd_ada, amp: 0.9
    end
    sleep 0.125
  end
 
 
  live_loop :hihat do
    with_fx :lpf, cutoff: 90, amp: 1 do |h|
      if (@is_drums_on)
        control h, amp: 1, cutoff: 100
      else
        control h, amp: 1, cutoff: 90
      end
 
      sync :ta
      sample :drum_cymbal_closed , amp: rrand(0.8, 1), attack:0.1,  release: 0.5
      sync :ka
      if (@is_drums_on == true)
        sample :drum_cymbal_closed , amp: rrand(0.5, 0.8), attack:0.1,  release: 0.5
      end
      sync :di
      sample :drum_cymbal_closed  , amp: rrand(0.8, 1), attack:0.1,  release: 0.5
      sync :mi
      if (@is_drums_on == true)
        sample :drum_cymbal_closed ,amp: rrand(0.5, 0.8), attack:0.1,  release: 0.5
      end
 
    end
    sleep 0.125
  end
 
  live_loop :hihat2 do
    with_fx :lpf, cutoff: 80, amp: 0.8  do |h|
      if (@is_drums_on == true)
        control h, amp: 1, cutoff: 100
      else
        control h, amp: 0.9, cutoff: 80
      end
      sync :first
      sync :four
      sync :di
      value = rrand(0.5, 1)
      sample :drum_cymbal_closed, amp: value, attack:0.01,  release: 0.5
      sleep 0.0625
      sample :drum_cymbal_closed, amp: value, attack:0.01,  release: 0.5
      sleep 0.0625
      sample :drum_cymbal_closed, amp: value, attack:0.01,  release: 0.5
      sleep 0.0625
      sample :drum_cymbal_closed, amp: value, attack:0.01,  release: 0.5
      sleep 0.0625
    end
  end
 
  live_loop :hihat3 do
    with_fx :lpf, cutoff: 80, amp: 0.8  do |h|
      if (@is_drums_on == true)
        control h, amp: 1, cutoff: 100
      else
        control h, amp: 0.8, cutoff: 80
      end
      sync :third
      sync :four
      sync :di
      value = rrand(0.5, 1)
      sample :drum_cymbal_closed, amp: value, attack:0.01,  release: 0.5
      sleep 0.0625
      sample :drum_cymbal_closed, amp: value, attack:0.01,  release: 0.5
      sleep 0.0625
      sample :drum_cymbal_closed, amp: value, attack:0.01,  release: 0.5
      sleep 0.0625
 
      sync :mi
      sample :drum_cymbal_closed, amp: value, attack:0.01,  release: 0.5
      sleep 0.0625
      sample :drum_cymbal_closed, amp: value, attack:0.01,  release: 0.5
      sleep 0.0625
      sample :drum_cymbal_closed, amp: value, attack:0.01,  release: 0.5
      sleep 0.0625
      sample :drum_cymbal_closed, amp: value, attack:0.01,  release: 0.5
 
    end
  end
 
  with_fx :gverb, mix: 0.7, spread: 0.7, damp: 0.6 do
    with_fx :lpf, cutoff: 50 do |hlpf|
      live_loop :allways_on_arpeggio do
        use_synth :mod_fm
        use_synth_defaults pulse_width: 0.1, amp: 0.4
 
        sync :first
        sync :one
        sync :ta
        rrand_i(2, 12).times do
          play scale(@current_chord, :dorian).ring.tick, pan: rrand(-0.5, 0.5),  sustein: 0.3, release: 0.15
          sleep [0.25, 0.125, 0.0675].choose
        end
      end
    end
  end
 
  live_loop :arpeggio do
    use_synth :mod_tri
    triggered_instrument, velocity = get_triggered_instrument
 
    if (triggered_instrument == :arpeggio_trigger)
 
      sync :ta
      rrand_i(2, 12).times do
        play scale(@current_chord, :dorian).ring.tick, pan: 1,  sustein: 0.3, release: 0.25, amp: velocity / 128.0
        sleep [0.25, 0.125, 0.0625].choose
      end
    end
  end
end
 
live_loop :main_loop do
  get_off_instrument
  sleep 0.3
end
 
live_loop :main_loop2 do
  control_instrument
  sleep 0.1
end
 
 
live_loop :master do
  cue :first
  beatFunc
  cue :second
  beatFunc
  cue :third
  beatFunc
  cue :fourth
  beatFunc
  cue :fifth
  beatFunc
  cue :sixth
  beatFunc
end
 
define :bar do
  cue :ta
  cue :smallest
  sleep 0.25
  cue :ka
  cue :smallest
  sleep 0.25
  cue :di
  cue :smallest
  sleep 0.25
  cue :mi
  cue :smallest
  sleep 0.25
end
 
define :beatFunc do
  @current_chord = @m.tick
  cue :one
  cue :quarter
  bar
  cue :two
  cue :quarter
  bar
  cue :three
  cue :quarter
  bar
  cue :four
  cue :quarter
  bar
end
 
 
