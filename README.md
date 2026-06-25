# TWDayOff
![PowerShell](https://img.shields.io/badge/PowerShell-7+-5391FE?logo=powershell&logoColor=white)
![Platform](https://img.shields.io/badge/Platform-Windows-0078D6?logo=windows11&logoColor=white)
![HTML](https://img.shields.io/badge/Output-HTML-E34F26?logo=html5&logoColor=white)
![License](https://img.shields.io/github/license/sugigu/TWDayOff)
![Repo Size](https://img.shields.io/github/repo-size/sugigu/TWDayOff)
![Last Commit](https://img.shields.io/github/last-commit/sugigu/TWDayOff)
![Taiwan](https://img.shields.io/badge/Taiwan-Weekends%20%2B%20Official%20Holidays-green)

A tiny utility that answers one simple question: "When's my next day off?"

A tiny local HTML day-off countdown for Taiwan.

TWDayOff generates a simple HTML file that shows how many days remain until the next day off.

It is designed for people with a normal weekend schedule in Taiwan.

No holiday names. No calendar clutter.

Just the only thing that matters:

- `D-3` = 3 days until the next day off
- `放假` = today is a day off

## Features

- Generates a local HTML file
- Shows `D-n` before the next day off
- Shows `放假` on the day off
- Includes weekends
- Includes Taiwan government holidays
- Excludes Armed Forces Day
- Works with Windhawk Taskbar Clock Custom WebContent
- Can be used anywhere a local HTML page is accepted

## Usage

```powershell
pwsh .\TWDayOff.ps1
```

## Use Cases

- Windhawk Taskbar Clock Custom WebContent
- Local dashboards
- Browser source
- Any local HTML display

## License

MIT
