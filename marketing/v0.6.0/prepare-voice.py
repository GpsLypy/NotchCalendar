"""Generate public product narration only; no user data is sent to speech service."""
import asyncio
import json
from pathlib import Path
import edge_tts

ROOT = Path(__file__).resolve().parent
VOICE = ROOT / 'assets' / 'voice'
VOICE.mkdir(parents=True, exist_ok=True)
items = json.loads((ROOT / 'narration.json').read_text())

async def main():
    semaphore = asyncio.Semaphore(2)
    async def generate(index, item):
        async with semaphore:
            target = VOICE / item['voiceFile']
            if target.exists() and target.stat().st_size > 1000:
                return
            for attempt in range(3):
                try:
                    await asyncio.wait_for(edge_tts.Communicate(
                        item['spoken'], 'zh-CN-XiaoxiaoNeural', rate='+5%'
                    ).save(str(target)), timeout=45)
                    print(f'Voice {index}/{len(items)}', flush=True)
                    return
                except Exception:
                    if attempt == 2:
                        raise
                    await asyncio.sleep(2)
    await asyncio.gather(*(generate(i, item) for i, item in enumerate(items, 1)))

asyncio.run(main())
