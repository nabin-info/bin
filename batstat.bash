#!/bin/bash
# vim: set ai et ts=2 sw=2 sts=0:
s2hms() {
  local -i hh mm ss=${1:-0}
  : $(( (ss > 0) || (ss *= -1) ))
  : $(( hh = ss / 3600 , ss %= 3600 ))
  : $(( mm = ss /   60 , ss %=   60 ))
  printf '%02d:%02d:%02d' ${hh} ${mm} ${ss}
}

# main()
{
  cd /sys/class/power_supply
  for bt in BAT*/ 
  do 
    if cd ${bt} ; then
      typeset st= cp=
      {
        st=$(<status)
        cp=$(<capacity)
        : ${st:=Error} ${cp:=Error} 
      } 2>/dev/null

      typeset -i en= ef= ed=
      { 
        if [[ -r charge_now ]]; then
          en=$(<charge_now)
          ef=$(<charge_full)
          ed=$(<charge_full_design)
        elif [[ -r energy_now ]]; then
          en=$(<energy_now)
          ef=$(<energy_full)
          ed=$(<energy_full_design)
        fi
      } 2>/dev/null

      typeset -i er=
      {
        if [[ -r power_now ]]; then
          er=$(<power_now)
        elif [[ -r current_now ]]; then
          er=$(<current_now)
        fi
      } 2>/dev/null

      typeset -i te=
      {
        if [[ $st = "Charging" ]]; then
          te=$((ef - en))
        elif [[ $st = "Discharging" ]]; then
          te=$((en))
        fi
        : $(( (te < ef) || (te = 0) ))
      } 2>/dev/null

      if [[ 0 -eq $((en * ef * er * te)) ]] ; then
        printf '%s : %s%% [%s]\n' ${bt%/} ${cp} ${st}
      else
        : $(( (ed > ef) || (ed = ef) ))
        : $(( cp = (en * 100) / ef ))
        : $(( dp = (ef * 100) / ed ))
        typeset -i ts=$(( (3600 * te) / er))
        th="$(s2hms $ts)"
        printf '%s : %d%% [%s] (%s) {%d%%}\n' ${bt%/} ${cp} ${st} ${th} ${dp}
      fi

      cd ..
    fi
  done
}

