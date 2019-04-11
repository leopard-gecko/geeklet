# ８時間後から１5時間後までのスクリプト

# 場所のURL
weather_url="https://www.accuweather.com/en/jp/koto-ku/221230/weather-forecast/221230"

# amとpmの色  30 黒、31 赤、32 緑、33 黄、34 青、35 マゼンタ、36 シアン、37 白、0 デフォルトのまま
AM_COLOR=31
PM_COLOR=34

# 何時間後？
later=8

# 元データ取得
my_hour=`date +%H` ; my_hour=`expr $my_hour + $later`
curl_data=`curl  -H 'User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X)' --silent ${weather_url/weather-forecast/hourly-weather-forecast}"?hour=$my_hour"`

# 時刻を取得
current_time=(`echo "$curl_data" | grep -A 37 "overview-hourly" | grep -A 29 "first-col" | sed -e 's/<[^>]*>//g' -e 's/^ *//' | tr -d "\r"`)

# 天気を取得（スペースを含んだデータを配列に格納）
_IFS="$IFS";IFS="_"
current_weather=(`echo "$curl_data" | grep -A 67 "overview-hourly" | grep -A 23 "Forecast" | sed -e 's/<[^>]*>//g' -e 's/^ *//' -e '1,2d'  -e 's/ \&amp;/\&/g' -e 's/[[:cntrl:]]//g' | tr -s '\r\n' '_'`)
IFS="$_IFS"

# 天気アイコンのナンバーを取得
current_icon=(`echo "$curl_data" | grep -A 38 "overview-hourly" | grep 'icon' | sed -e 's/[^"]*"\([^"]*\)".*/\1/' | tr -cd '0123456789\n'`)

# 時刻を左揃え８桁で表示
printf "%-8s" ${current_time[*]} | sed -e s/am/`echo "\033[0;${AM_COLOR}mam\033[0m"`/g -e s/pm/`echo "\033[0;${PM_COLOR}mpm\033[0m"`/g

# 天気を左揃え８桁かつ２段で表示
for (( i=0; i < ${#current_weather[@]}; ++i))
do
echo "${current_weather[$i]}" | awk '{printf "%-8s", $1}'
done
echo
for (( i=0; i < ${#current_weather[@]}; ++i))
do
echo "${current_weather[$i]}" | awk '{printf "%-8s", $2}'
done

# 天気アイコンを取得して保存（取得するアイコンのナンバーはゼロパディングする）
for (( i=0; i < ${#current_icon[@]}; ++i))
do
current_icon[$i]=`printf "%02d" ${current_icon[$i]}`
echo "https://vortex.accuweather.com/adc2010/images/slate/icons/${current_icon[$i]}-s.png" | xargs curl --silent -o /tmp/weather_hour_`expr $i + $later`.png
done