# Labtainer Quiz Kılavuzu

[English](QUIZ_GUIDE.md) | **Türkçe**

Lab geliştiricileri ve eğitmenler için quiz ekleme, çalıştırma, cevapları toplama ve sanal makine paketinin kurulum rehberi.

## İçindekiler

- [Genel bakış](#genel-bakış)
- [Kurulum (sanal makine paketi)](#kurulum-sanal-makine-paketi)
- [Her güncellemede ne olur](#her-güncellemede-ne-olur)
- [Laba quiz ekleme](#laba-quiz-ekleme)
- [Bir laba birden fazla quiz](#bir-laba-birden-fazla-quiz)
- [Dosya formatı](#dosya-formatı)
- [Soru tipleri](#soru-tipleri)
- [Önkoşullar](#önkoşullar)
- [Quiz çalıştırma](#quiz-çalıştırma)
- [Cevap kaydı](#cevap-kaydı)
- [Eğitmen işlemleri](#eğitmen-işlemleri)
- [Çok kullanıcılı sunucu](#çok-kullanıcılı-sunucu)
- [Hata mesajları](#hata-mesajları)
- [Sınırlar](#sınırlar)

## Genel bakış

Quiz, bir labın kendi `config` klasöründe duran düz metin dosyasıdır. Ayrı bir paket gerekmez, image yeniden derlenmez. Dosya laba konduğu anda `quiz` komutu onu bulur.

Quiz öğrencinin Linux terminalinde çalışır, lab container'larının içinde değil. Bu yüzden lab çalışmıyorken de açılabilir.

| Özellik | Orijinal Labtainer | Quiz modülü ile |
|---|---|---|
| Bilgi metni (`Preface`) | Var | Var |
| Doğru/yanlış (`TrueFalse`) | Var | Var |
| Çoktan seçmeli (`MultipleChoice`) | Yok | Var, notlanır |
| Anket (`Survey`) | Yok | Var, notlanmaz |
| Cevapların kaydı | Yok | Her deneme kaydedilir |
| Cevapların `.lab` dosyasına girmesi | Yok | `stoplab` ekler |

### Kim ne yapar

| Rol | Yapılacak | Modül gerekli mi |
|---|---|---|
| Lab geliştiricisi | `.quiz` dosyasını yazar, laba ekler, sonuna kadar dener | Evet |
| Öğrenci | Quiz'i çalıştırır, labı `stoplab` ile durdurur, `.lab` dosyasını gönderir | Evet, yeni tipler ve kayıt için |
| Eğitmen | `.lab` dosyalarını toplar, notlandırır, cevapları okur | Hayır, `gradelab` değişmeden çalışır |

## Kurulum (sanal makine paketi)

Paket, kendi sanal makinesinde Labtainer kullananlar içindir. Dosya adı `labtainer-quiz.tar.gz`.

1. Paketi sanal makineye kopyalayın. Paylaşılan klasör, `scp` veya tarayıcıdan indirme olabilir.
2. Çalışan bir lab varsa `stoplab` ile durdurun.
3. Labtainer'ı çalıştıran kullanıcıyla aşağıdaki komutları çalıştırın. `sudo` kullanmayın.

```bash
tar xzf labtainer-quiz.tar.gz
cd labtainer-quiz
./install.sh
```

Başarılı kurulumda `Quiz module installed in ...` yazar.

Kurulum programı Labtainer'ı `LABTAINER_DIR` değişkeninden, o yoksa `~/labtainer/trunk` altından bulur. Başka bir konum için:

```bash
LABTAINER_DIR=/baska/yol/labtainer/trunk ./install.sh
```

### Pakette ne var

| Dosya | Görevi |
|---|---|
| `install.sh` | Kurar, tekrar uygular ve kaldırır |
| `quiz` | Yeni quiz programı, Labtainer'ın `quiz` dosyasının yerini alır |
| `labutils_quiz.patch` | `labutils.py` içine, cevapları `.lab` dosyasına ekleyen üç satır koyar |
| `README.md` | Kısa İngilizce kullanım notu |

### Sistemde ne değişir

Yalnızca `trunk/scripts/labtainer-student/bin` altındaki iki dosya değişir: `quiz` ve `labutils.py`. Yedekleri aynı klasörde `.quiz_backup` içinde durur.

Kurulu olduğunu şu komutla görebilirsiniz, sonuç `1` olmalı:

```bash
grep -c 'quiz.json' ~/labtainer/trunk/scripts/labtainer-student/bin/labutils.py
```

`patch` komutu yoksa kurulum durur ve kurulum komutunu söyler, dosyalara dokunmaz:

```bash
sudo apt-get install patch
```

### Kaldırma

Komutu paket klasöründe çalıştırın, yani paketi silmeyin.

```bash
./install.sh --uninstall
```

Orijinal dosyalar geri gelir. Kayıtlı cevaplar ve `.quiz` dosyaları silinmez. Orijinal program `MultipleChoice` ve `Survey` sorularını sessizce atlar.

## Her güncellemede ne olur

> [!IMPORTANT]
> Her `update-labtainer.sh` çalıştırmasından sonra paket klasöründe `./install.sh` çalıştırın. Bir şey değişmemişse zararsızdır.

```bash
cd ~/labtainer/labtainer-student
update-labtainer.sh
cd ~/labtainer-quiz
./install.sh
```

`update-labtainer.sh` yeni sürümü `tar --keep-newer-files` ile açar. Yani diskteki dosya sürümdeki kopyadan yeniyse dokunmaz, eskiyse üzerine yazar. `install.sh` değiştirdiği dosyaların orijinal tarihini korur, böylece güncelleme sürümdeki yeni dosyaları normal şekilde alır.

| Güncellemede ne oluyor | Sonuç | Yapılacak |
|---|---|---|
| Sürümde `labutils.py` veya `quiz` daha yeni | Yeni sürüm yerine geçer, modülün o parçası gider | `./install.sh` yeniden uygular |
| Bu iki dosya sürümde değişmemiş | Modül yerinde kalır | `./install.sh` bir şey değiştirmez |
| Kendi adınızla eklediğiniz `.quiz` | Kalır | Yok |
| Labtainer ile gelen bir `.quiz` dosyasını düzenlediniz | Dosyanız sürümdekinden yeniyse kalır, eskiyse üzerine yazılır | Değişiklikleri kendi adınızla ayrı bir dosyada tutun |
| Kayıtlı cevaplar ve `.lab` dosyaları | Dokunulmaz | Yok |

> [!WARNING]
> Güncellemeden sonra `./install.sh` çalıştırılmazsa ve `quiz` değişmişse yeni tipler çalışmaz. `labutils.py` değişmişse quiz yine çalışır, ama cevaplar `.lab` dosyasına girmez ve bu hiçbir hata vermez.

### Yama reddedilirse

Şu mesaj, yeni Labtainer sürümünün yamanın dokunduğu kodu değiştirdiği anlamına gelir:

```text
This version of labutils.py does not accept the patch, nothing was changed.
```

Hiçbir dosya değişmez, sistem orijinal haliyle çalışır. Bu durumda yeni sürüme uygun bir paket gerekir.

### Yeni paket sürümü

- Yeni paket yalnızca `quiz` programını değiştiriyorsa açıp `./install.sh` çalıştırmak yeterlidir.
- `labutils_quiz.patch` de değiştiyse önce eski paketin klasöründe `./install.sh --uninstall`, sonra yeni paketle `./install.sh` çalıştırın.

## Laba quiz ekleme

1. Labın `config` klasörüne `.quiz` uzantılı bir dosya oluşturun. Dosya adı quiz'in adıdır, boşluk kullanmayın.
2. Soruları [dosya formatına](#dosya-formatı) göre yazın.
3. Quiz'i sonuna kadar çözerek deneyin.
4. Lab kılavuzuna quiz'in ne zaman ve hangi komutla yapılacağını yazın.

```text
~/labtainer/trunk/labs/telnetlab/config/telnet.quiz
```

Kısa bir başlangıç örneği:

```text
# telnetlab hazırlık quiz'i
0, Preface, "Bu quiz labdan önce kendinizi kontrol etmeniz içindir."
1, MultipleChoice, "Telnet varsayılan olarak hangi portu kullanır?", B,
   "Doğru.", "Yanlış, telnet 23 kullanır.", "",
   "22", "23", "80", "443"
2, TrueFalse, "Telnet trafiği düz metin olarak gider.", T, "", ""
3, Survey, "Bu lab ne kadar zordu?", "", "Kolay", "Orta", "Zor"
4, Survey, "Neyi iyileştirirdiniz?", ""
```

> [!IMPORTANT]
> Dosya soru soruldukça okunur. Hatalı bir soru, ancak sıra ona geldiğinde quiz'i durdurur ve o deneme kaydedilmez. Önkoşullu soruları görmek için bir kez de yanlış cevaplayarak deneyin.

Hazır örnekler `db-access`, `dmz-lab`, `dns` ve `iptables2` lablarının `config` klasörlerinde bulunur.

## Bir laba birden fazla quiz

Aynı `config` klasörüne birden fazla `.quiz` dosyası koymanız yeterlidir. Sayı sınırı yoktur.

```text
labs/telnetlab/config/pre.quiz
labs/telnetlab/config/post.quiz
labs/telnetlab/config/survey.quiz
```

Bu durumda düz `quiz` komutu soru sormaz, seçenekleri listeler:

```text
Multiple quizzes for this lab.  Pick one with the -q option: post pre survey
```

Öğrenci adı `.quiz` uzantısı olmadan verir:

```bash
quiz -q pre
```

Her quiz'in kendi kayıt dosyası olur (`pre.quiz.json`, `post.quiz.json`) ve `stoplab` hepsini `.lab` dosyasına ekler.

Quiz'ler birbirine bağlanamaz: önkoşullar yalnızca aynı dosyadaki soruları görür ve quiz'lerin sırasını program zorlamaz. Sırayı lab kılavuzunda belirtin.

## Dosya formatı

Her soru virgülle ayrılmış bir kayıttır. İlk iki alan her zaman kimlik ve tiptir.

| Kural | Ayrıntı |
|---|---|
| Kodlama | BOM'suz UTF-8. Türkçe karakterler desteklenir. BOM'lu dosyada ilk satır bozulur, Windows Not Defteri'nde dikkat edin. CRLF satır sonları sorun değildir. |
| Yorum | `#` ile başlayan satır atlanır, çok satırlı sorunun ortasında da olabilir. |
| Soru alt satıra geçiş | Satır `,` ile bitiyorsa soru alt satırda devam eder. Satır `\` ile bitiyorsa metin alt satırla birleşir, böylece uzun bir metin bölünebilir. |
| Boş satır | Kullanmayın. Sorular arasında ekrana `bad line?` yazar. Çok satırlı sorunun içinde soruyu keser ve quiz durur. |
| Metin | Metinleri çift tırnak içine alın. İçlerindeki virgül ayırıcı sayılmaz. |
| Metin içinde tırnak | İki kez yazın: `"Komut: ""ls -l"" ne yapar?"` |
| Metin içinde yeni satır | `\n` yazın. Gerçek ters bölü için `\\` yazın. |
| Boş alan | `""` yazın. Alan sayısı önemlidir, boş alan atlanamaz. |
| Tip adı | Büyük-küçük harf fark etmez: `TrueFalse`, `truefalse`. |
| Kimlik | Dosya içinde benzersiz olmalı. Rakam veya metin olabilir, küçük harfe çevrilerek kaydedilir. |
| Uzun satırlar | Ekrana yazılırken otomatik sarılır. |

## Soru tipleri

### Preface: bilgi metni

```text
KİMLİK, Preface, "Gösterilecek metin"
```

Metni gösterir, cevap istemez, kaydedilmez ve sayılmaz. Bağlam vermek için soruların önüne konur.

### TrueFalse: doğru/yanlış

```text
KİMLİK, TrueFalse, "Soru", cevap, "Doğru mesajı", "Yanlış mesajı", önkoşul
```

| Alan | Zorunlu | Değer |
|---|---|---|
| cevap | Evet | `T` veya `F` |
| Doğru mesajı | Evet | Doğru cevapta gösterilir, istemiyorsanız `""` |
| Yanlış mesajı | Evet | Yanlış cevapta gösterilir, istemiyorsanız `""` |
| önkoşul | Hayır | Başka bir sorunun kimliği |

Öğrenci yalnızca `T` veya `F` yazmalıdır, küçük harf de olur. `true`, boş giriş veya başka bir şey soruyu tekrar sormaz, yanlış sayılır. Bu, orijinal programın davranışıdır.

```text
3, TrueFalse, "nmap açık portları bulabilir.", T, "", ""
```

### MultipleChoice: çoktan seçmeli

```text
KİMLİK, MultipleChoice, "Soru", cevap, "Doğru mesajı", "Yanlış mesajı", önkoşul, "A şıkkı", "B şıkkı", ...
```

| Alan | Zorunlu | Değer |
|---|---|---|
| cevap | Evet | Doğru şıkkın harfi, küçük harf de olur |
| Doğru ve yanlış mesajı | Evet | Metin veya `""` |
| önkoşul | Evet | Kimlik, yoksa mutlaka `""` |
| şıklar | En az 2, en çok 26 | Sırayla A, B, C harfi otomatik verilir |

> [!WARNING]
> Önkoşul alanındaki `""` unutulursa ilk şık önkoşul sanılır ve soru hata vermeden hiç sorulmaz. Doğru sıra: `"Yanlış mesajı", "", "A şıkkı"`.

Geçersiz girişte soru yeniden sorulur, yanlış sayılmaz. Doğru cevabın harfi şıklar arasında yoksa quiz o soruya gelince durur.

### Survey: anket

```text
KİMLİK, Survey, "Soru", önkoşul, "A şıkkı", "B şıkkı"
KİMLİK, Survey, "Soru", önkoşul
```

Şık yazılırsa öğrenci birini seçer, şık yazılmazsa serbest metin girer ve boş bırakabilir. Önkoşul alanı zorunludur, yoksa `""` yazın.

Doğru cevap yoktur, geri bildirim gösterilmez ve yanlış sayısına girmez. Bir quiz yalnızca anketten oluşuyorsa sonda `Your responses have been recorded.` yazar.

## Önkoşullar

Önkoşul, bir soruyu yalnızca başka bir soru yanlış cevaplandıysa sorar. Eksik bilgiyi pekiştirmek veya yanlış yapan öğrenciden neden yaptığını öğrenmek için kullanılır.

```text
1, TrueFalse, "Telnet şifreli çalışır.", F, "", ""
2, MultipleChoice, "Şifreli uzak bağlantı için hangisi kullanılır?", B, "", "", 1, "telnet", "ssh"
3, Survey, "Yanlış yanıtlama nedeniniz neydi?", 1, "Bilmiyordum", "Dikkatsizlik"
```

- Önkoşul olarak verilen soru dosyada daha önce gelmelidir. Sonra gelirse bu soru hiç sorulmaz.
- Kimlikler büyük-küçük harf ayrımı yapmaz.
- Anket ve Preface yanlış sayılmadığı için önkoşul olamaz, onlara bağlı soru hiç sorulmaz.
- Atlanan soru kayıt dosyasına yazılmaz ve sayılmaz.
- Her üç soru tipi de önkoşul alabilir.

## Quiz çalıştırma

Quiz, labı başlattığınız terminalde ve `labtainer-student` klasöründe çalıştırılır. Başka klasörden çalıştırılırsa `The lab has no quizzes` yazar.

```bash
cd ~/labtainer/labtainer-student
```

| Durum | Komut |
|---|---|
| Lab çalışıyor, tek quiz var | `quiz` |
| Lab çalışıyor, birden fazla quiz var | `quiz -q pre` |
| Lab çalışmıyor | `quiz -l iptables2` |
| Lab çalışmıyor, birden fazla quiz var | `quiz -l dns -q post` |
| Birden fazla lab çalışıyor | `quiz -l telnetlab` |
| Yardım | `quiz -h` |

| Soru | Öğrenci ne yazar |
|---|---|
| TrueFalse | `T` veya `F`, sonra Enter |
| MultipleChoice | Şık harfi, sonra Enter |
| Survey (şıklı) | Şık harfi, sonra Enter |
| Survey (metin) | Serbest metin, sonra Enter |

Sonda yanlış sayısı veya `You answered all questions correctly.` yazar. Quiz istendiği kadar tekrar çözülebilir, her biri ayrı deneme olarak kaydedilir. `Ctrl+C` quiz'den çıkar ve o deneme kaydedilmez.

## Cevap kaydı

Quiz tamamlanınca cevaplar şu dosyaya eklenir. Eski denemeler silinmez.

```text
labtainer-student/.tmp/<lab>/<quiz>.quiz.json
```

```json
[
    {
        "time": "2026-10-31 20:35:54.837782",
        "responses": [
            {
                "id": "1",
                "type": "multiplechoice",
                "question": "Telnet varsayılan olarak hangi portu kullanır?",
                "response": "A",
                "response_text": "22",
                "correct": false
            }
        ]
    }
]
```

| Alan | Anlamı |
|---|---|
| `time` | Denemenin bitiş zamanı |
| `id`, `type`, `question` | Sorunun kimliği, tipi ve metni |
| `response` | Yazılan harf. Metin anketinde `null` |
| `response_text` | Seçilen şıkkın metni veya yazılan metin. TrueFalse'ta `null` |
| `correct` | `true` veya `false`. Ankette `null` |

### Paketleme

`stoplab`, bu dosyaları `~/labtainer_xfer/<lab>/` altındaki `.lab` dosyasına ekler. `stoplab`'den sonra çözülen quiz, lab bir sonraki durdurulmasında pakete girer. Bu nedenle son quiz'den sonra lab bir kez daha başlatılıp durdurulmalıdır.

`redo` (`labtainer -r`) cevapları silmez. Tek istisna: `read_pre.txt` içeren bir labın ilk açılışındaki `Continue? (y/n)` sorusuna `y` dışında cevap verilirse Labtainer `.tmp/<lab>` klasörünü siler.

## Eğitmen işlemleri

### Quiz'i öğrencilere ulaştırma

- **Elle:** `.quiz` dosyasını her öğrencinin `~/labtainer/trunk/labs/<lab>/config/` klasörüne kopyalatın.
- **IModule:** Labtainer'ın eğitmen dağıtım yöntemi. `.quiz` dosyalarını yolları `labs` klasörüne göreli bir tar dosyasına koyup web'de yayınlayın, örneğin `telnetlab/config/pre.quiz`. Öğrenciler `imodule <url>` çalıştırır. Dosyalar sonraki her `update-labtainer.sh` veya `imodule -u` ile yenilenir.

Öğrencilerin ayrıca quiz modülünü kurması gerekir, IModule yalnızca `labs` klasörüne yazar.

### Cevapları toplama

1. Öğrenciler `stoplab` çalıştırır ve `~/labtainer_xfer/<lab>/` içindeki `.lab` dosyasını gönderir.
2. Dosyaları kendi `~/labtainer_xfer/<lab>/` klasörünüze koyun.
3. Lab notlandırması için `labtainer-instructor` klasöründen `gradelab <lab>` çalıştırın. Quiz dosyaları notlandırmayı etkilemez.

`gradelab` quiz cevaplarını göstermez, onları `.lab` dosyasından okumanız gerekir. `.lab` bir zip dosyasıdır:

```bash
python3 -m zipfile -l ogrenci_at_umich.edu.telnetlab.lab
python3 -m zipfile -e ogrenci_at_umich.edu.telnetlab.lab cevaplar/
```

### Tüm öğrencileri tek tabloya alma

Aşağıdaki kodu `quiz_report.py` olarak kaydedin. Bir labın tüm `.lab` dosyalarından, her cevap için bir satır içeren CSV üretir.

```python
import csv, glob, json, os, sys, zipfile

lab = sys.argv[1]
writer = csv.writer(sys.stdout)
writer.writerow(['student', 'quiz', 'attempt', 'time', 'id', 'type', 'response', 'response_text', 'correct'])
for path in sorted(glob.glob(os.path.expanduser('~/labtainer_xfer/%s/*.lab' % lab))):
    student = os.path.basename(path).rsplit('.', 2)[0]
    with zipfile.ZipFile(path) as z:
        for name in z.namelist():
            if name.endswith('.quiz.json'):
                for number, attempt in enumerate(json.loads(z.read(name)), 1):
                    for r in attempt['responses']:
                        writer.writerow([student, name[:-len('.quiz.json')], number, attempt['time'], r['id'],
                                         r['type'], r['response'], r['response_text'], r['correct']])
```

```bash
python3 quiz_report.py telnetlab > telnetlab_quiz.csv
```

## Çok kullanıcılı sunucu

Çok kullanıcılı Labtainer yamasında quiz modülü zaten vardır, `install.sh` kullanılmaz. `setup.sh` bunu `/home/student/labtainer` üzerine uygular, öğrenci kopyaları da oradan oluşur.

- Yeni kullanıcılar modülü `open.sh` ile alır. Mevcut kullanıcılar `setup.sh` yeniden çalıştırıldığında alır.
- Her öğrencinin kendi Labtainer kopyası olduğu için yeni `.quiz` dosyaları `/home/student/labtainer` yanında mevcut öğrencilerin kopyalarına da konmalıdır.
- Komutlar aynıdır. Her öğrenci yalnızca kendi labını görür ve cevapları ayrı tutulur.

## Hata mesajları

| Mesaj | Neden | Çözüm |
|---|---|---|
| `The lab has no quizzes` | Labda `.quiz` yok, lab adı yanlış veya yanlış klasördesiniz | `labtainer-student` klasörüne geçin, adı kontrol edin |
| `No labs are currently running...` | Çalışan lab yok | `quiz -l <lab>` kullanın |
| `multiple labs running...` | Birden fazla lab açık | `quiz -l <lab>` kullanın |
| `Multiple quizzes for this lab...` | Labda birden fazla quiz var | `-q` ile seçin |
| `Given quiz ... not one of the quizzes` | `-q` adı yanlış | Mesajdaki adlardan birini yazın |
| `Not enough elements in this question` | Alan eksik veya çok satırlı soruda boş satır var | Alanları sayın, `""` ekleyin |
| `Answer X of question N is not one of its options` | Doğru cevap harfi şıklarda yok | Harfi veya şıkları düzeltin |
| `Unknown question type ...` | Tip adı yanlış yazılmış, soru atlanır | Tip adını düzeltin |
| `bad line?` | Boş veya bozuk satır | Satırı silin |
| Soru hiç sorulmuyor | Çoktan seçmelide önkoşul `""` unutulmuş veya önkoşul sorusu doğru yapılmış | Alanları kontrol edin |
| Cevaplar `.lab` içinde yok | Modül güncellemeyle gitmiş veya quiz `stoplab`'den sonra çözülmüş | `./install.sh` çalıştırın, labı başlatıp durdurun |

## Sınırlar

- **Sınav için değildir.** Doğru cevaplar `.quiz` dosyasında düz metindir ve öğrenci okuyabilir. Öğrenci kayıt dosyasını `stoplab`'den önce değiştirebilir.
- **Not ekranı yok.** `gradelab` quiz sonuçlarını göstermez ve nota katmaz.
- **Tek cevap.** Çoktan seçmeli soruda birden fazla doğru şık desteklenmez.
- **Soru ve şık sırası sabittir.** Karıştırma ve öğrenciye göre değiştirme yoktur.
- **Quiz zorunlu değildir.** Lab başlatma veya durdurma quiz çözülüp çözülmediğine bakmaz.
