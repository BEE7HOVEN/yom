# 시놀로지 NAS 자동매매 봇 구축 순서도

## 전체 구조

```
DS920+ (Docker)
├── code-server        → 브라우저에서 VS Code + Claude 확장
├── 자동매매 봇        → Python (ccxt)
├── Flask 대시보드     → 브라우저에서 봇 상태 모니터링
└── SQLite DB          → 거래 내역 저장
        ↓
어디서든 브라우저로 접속
```

---

## STEP 1. 사전 준비

- [ ] 거래소 API 키 발급 (업비트 / 바이낸스 등)
- [ ] DS920+ DSM에서 Docker 설치 확인
- [ ] 공유기 포트포워딩 설정 (외부 접속용)
- [ ] 시놀로지 DDNS 설정 (고정 주소 확보)

---

## STEP 2. code-server 설치 (브라우저 VS Code)

```yaml
# docker-compose.yml
services:
  code-server:
    image: lscr.io/linuxserver/code-server
    container_name: code-server
    environment:
      - PASSWORD=비밀번호설정
      - TZ=Asia/Seoul
    volumes:
      - ./config:/config
      - ./projects:/home/coder/projects
    ports:
      - "8443:8443"
    restart: unless-stopped
```

- 접속: `http://NAS-IP:8443`
- Claude Code 확장프로그램 설치 (Open VSX에서 `Anthropic.claude-code` 검색)

---

## STEP 3. 자동매매 봇 개발

```
projects/
└── trading-bot/
    ├── bot.py          # 매매 로직
    ├── strategy.py     # 전략 (RSI, 이동평균 등)
    ├── config.py       # API 키, 설정값
    ├── db.py           # DB 연결 (SQLite)
    └── requirements.txt
```

**주요 라이브러리:**
- `ccxt` - 거래소 연동
- `pandas`, `ta` - 기술적 분석
- `sqlite3` - 거래 내역 저장
- `apscheduler` - 주기적 실행

---

## STEP 4. Flask 대시보드 개발

```
projects/
└── dashboard/
    ├── app.py              # Flask 메인
    ├── templates/
    │   └── index.html      # 대시보드 UI
    └── static/
        └── chart.js        # 차트
```

**대시보드 기능:**
- 현재 잔고 / 수익률 표시
- 거래 내역 테이블
- 봇 상태 (실행중 / 중지)
- 봇 ON / OFF 버튼
- 실시간 로그
- 차트 (Chart.js)

- 접속: `http://NAS-IP:5000`

---

## STEP 5. Docker Compose 통합

```yaml
# docker-compose.yml (전체)
services:
  code-server:
    image: lscr.io/linuxserver/code-server
    ports:
      - "8443:8443"
    volumes:
      - ./projects:/home/coder/projects
    restart: unless-stopped

  trading-bot:
    build: ./projects/trading-bot
    container_name: trading-bot
    volumes:
      - ./data:/app/data
    restart: unless-stopped

  dashboard:
    build: ./projects/dashboard
    container_name: flask-dashboard
    ports:
      - "5000:5000"
    volumes:
      - ./data:/app/data
    depends_on:
      - trading-bot
    restart: unless-stopped
```

---

## STEP 6. 외부 접속 설정

```
인터넷
  ↓
공유기 포트포워딩
  ├── 8443 → NAS (code-server)
  └── 5000 → NAS (Flask 대시보드)
  ↓
시놀로지 DDNS (예: mybot.synology.me)
```

- 외부에서 접속:
  - VS Code: `http://mybot.synology.me:8443`
  - 대시보드: `http://mybot.synology.me:5000`

---

## STEP 7. 보안 설정 (필수)

- [ ] code-server 비밀번호 설정
- [ ] Flask 대시보드 로그인 기능 추가
- [ ] HTTPS 적용 (Let's Encrypt 또는 시놀로지 인증서)
- [ ] API 키 환경변수로 관리 (`.env` 파일)

---

## 최종 흐름 요약

```
[브라우저]
    │
    ├── :8443 → code-server (VS Code + Claude로 코딩)
    │
    └── :5000 → Flask 대시보드
                    │
                    └── SQLite DB ← 자동매매 봇 (ccxt)
                                          │
                                    [거래소 API]
```
