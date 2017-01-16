#!/bin/bash
# vim: set ai et ts=2 sw=2 sts=0:
s2hms() {
  local -i hh mm ss=${1:-0}
  : $(( (ss > 0) || (ss *= -1) ))
  : $(( (hh = ss / 3600) && (ss %= 3600) ))
  : $(( (mm = ss /   60) && (ss %=   60) ))
  printf '%02d:%02d:%02d' ${hh} ${mm} ${ss}
}

{
  cd /sys/class/power_supply
  for bt in BAT*/ 
  do 
    if cd ${bt} ; then
      { 
        st=$(<status)
        cp=$(<capacity)
        : ${st:=Error} ${cp:=Error} 

        declare -i en=0 ef=0 ed=0
        if [[ -r charge_now ]]; then
          en=$(<charge_now)
          ef=$(<charge_full)
          ed=$(<charge_full_design)
        elif [[ -r energy_now ]]; then
          en=$(<energy_now)
          ef=$(<energy_full)
          ed=$(<energy_full_design)
        fi

        declare -i er=0
        if [[ -r power_now ]]; then
          declare -i er=$(<power_now)
        elif [[ -r current_now ]]; then
          declare -i er=$(<current_now)
        fi

        declare -i te=0
        if [[ $st = "Charging" ]]; then
          declare -i te=$((ef - en))
        elif [[ $st = "Discharging" ]]; then
          declare -i te=$((en))
        fi
        : $(( (te < ef) || (te = 0) ))
      } 2>/dev/null

      if ((en * ef * er * te == 0)); then
        printf '%s : %s%% [%s]\n' ${bt%/} ${cp} ${st}
      else
        : $(( (ed > ef) || (ed = ef) ))
        : $(( cp = (en * 100) / ef ))
        : $(( dp = (ef * 100) / ed ))
        declare -i ts=$(( (3600 * te) / er))
        th="$(s2hms $ts)"
        printf '%s : %d%% [%s] (%s) {%d%%}\n' ${bt%/} ${cp} ${st} ${th} ${dp}
      fi

      cd ..
    fi
  done
}

