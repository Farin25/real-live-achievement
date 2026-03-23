// src/pages/index.js
import React from 'react';
import clsx from 'clsx';
import Link from '@docusaurus/Link';
import useDocusaurusContext from '@docusaurus/useDocusaurusContext';
import Layout from '@theme/Layout';
import styles from './index.module.css';

const content = {
  de: {
    heroPre: 'Achievement-System für das echte Leben',
    heroTitle: ['Raus. Erleben.', 'Achievement.'],
    heroSub: 'Upmark belohnt dich nicht für Zeit vor dem Bildschirm sondern dafür, dass du rausgehst, die Welt entdeckst und Dinge erlebst, die zählen.',
    ctaPrimary: 'App entdecken',
    ctaVideo: 'Demo ansehen',
    featuredLabel: 'Aus der App',
    featuredTitle: 'Echte Achievements für echtes Leben',
    achievements: [
      { icon: '🌍', title: 'Traveler I',     desc: '3 verschiedene Länder besucht',               rarity: 'Common'   },
      { icon: '🏔️', title: 'Mountain Goat',  desc: 'Berg über 2000 m bestiegen',                  rarity: 'Rare'     },
      { icon: '🌅', title: 'Golden Hour',    desc: 'Sonnenauf- oder -untergang draußen erlebt',   rarity: 'Common'   },
      { icon: '🏕️', title: 'Bushcamper',    desc: 'Eine Nacht in der Wildnis übernachtet',       rarity: 'Uncommon' },
      { icon: '🚶', title: 'Night Walker',   desc: 'Mehr als 5 km zwischen 22–4 Uhr gelaufen',   rarity: 'Uncommon' },
      { icon: '✈️', title: 'Time Traveler',  desc: '3 Zeitzonen an einem einzigen Tag besucht',  rarity: 'Epic'     },
    ],
    howTitle: 'Wie es funktioniert',
    how: [
      { num: '01', title: 'App herunterladen',  desc: 'Verfügbar für Android ab Juli 2026.' },
      { num: '02', title: 'Leben leben',         desc: 'GPS, Wetter, Schritte die App trackt automatisch im Hintergrund.' },
      { num: '03', title: 'Achievements sammeln',desc: 'Jedes Achievement ist ein Moment den du wirklich erlebt hast.' },
    ],
    videoTitle: 'Werbevideo',
    ctaTitle: 'Bereit für echte Abenteuer?',
    ctaSub: 'Release Juli 2026 · Android',
    ctaBtn: 'Newsletter abonnieren',
    ctaBtnSub: 'Kein Spam. Jederzeit abmeldbar.',
    rarityLabel: { Common: 'Common', Uncommon: 'Uncommon', Rare: 'Rare', Epic: 'Epic' },
    achievLink: 'Alle Achievements ansehen →',
  },
  en: {
    heroPre: 'Achievement system for real life',
    heroTitle: ['Go out. Live.', 'Achieve.'],
    heroSub: "Upmark doesn't reward screen time it rewards you for going outside, exploring the world, and experiencing things that actually matter.",
    ctaPrimary: 'Discover the App',
    ctaVideo: 'Watch Demo',
    featuredLabel: 'From the App',
    featuredTitle: 'Real achievements for real life',
    achievements: [
      { icon: '🌍', title: 'Traveler I',     desc: 'Visited 3 different countries',               rarity: 'Common'   },
      { icon: '🏔️', title: 'Mountain Goat',  desc: 'Climbed a mountain over 2000 m',              rarity: 'Rare'     },
      { icon: '🌅', title: 'Golden Hour',    desc: 'Outside during a sunrise or sunset',          rarity: 'Common'   },
      { icon: '🏕️', title: 'Bushcamper',    desc: 'Spent a night in the wilderness',             rarity: 'Uncommon' },
      { icon: '🚶', title: 'Night Walker',   desc: 'More than 5 km walked between 10 PM – 4 AM', rarity: 'Uncommon' },
      { icon: '✈️', title: 'Time Traveler',  desc: 'Visited 3 time zones in a single day',       rarity: 'Epic'     },
    ],
    howTitle: 'How it works',
    how: [
      { num: '01', title: 'Download the app',      desc: 'Available for Android starting July 2026.' },
      { num: '02', title: 'Live your life',          desc: 'GPS, weather, steps the app tracks automatically in the background.' },
      { num: '03', title: 'Collect achievements',    desc: 'Every achievement is a moment you actually experienced.' },
    ],
    videoTitle: 'Promo Video',
    ctaTitle: 'Ready for real adventures?',
    ctaSub: 'Release July 2026 · Android',
    ctaBtn: 'Subscribe to Newsletter',
    ctaBtnSub: 'No spam. Unsubscribe anytime.',
    rarityLabel: { Common: 'Common', Uncommon: 'Uncommon', Rare: 'Rare', Epic: 'Epic' },
    achievLink: 'View all achievements →',
  },
};

function AchievementCard({ icon, title, desc, rarity, rarityLabel }) {
  return (
    <div className={clsx(styles.achievCard, styles['rarity' + rarity])}>
      <div className={styles.achievTop}>
        <span className={styles.achievIcon}>{icon}</span>
        <span className={styles.achievRarity}>{rarityLabel}</span>
      </div>
      <strong className={styles.achievTitle}>{title}</strong>
      <p className={styles.achievDesc}>{desc}</p>
    </div>
  );
}

export default function Home() {
  const { siteConfig, i18n } = useDocusaurusContext();
  const locale = i18n.currentLocale;
  const t = content[locale] ?? content.de;

  return (
    <Layout title={siteConfig.title} description="Achievement system for real-world events">

      {/* ── HERO ── */}
      <header className={styles.hero}>
        <div className={styles.heroNoise} aria-hidden="true" />
        <div className={clsx('container', styles.heroInner)}>
          <p className={styles.heroPre}>
            <span className={styles.heroDot} aria-hidden="true" />
            {t.heroPre}
          </p>
          <h1 className={styles.heroTitle}>
            <span className={styles.heroLine1}>{t.heroTitle[0]}</span>
            <span className={styles.heroLine2}>{t.heroTitle[1]}</span>
          </h1>
          <p className={styles.heroSub}>{t.heroSub}</p>
          <div className={styles.heroCtas}>
            <Link className={styles.ctaPrimary} to="/docs/intro">
              {t.ctaPrimary} →
            </Link>
            <Link className={styles.ctaGhost} to="#demo">
              ▶ {t.ctaVideo}
            </Link>
          </div>
        </div>

        {/* Floating cards */}
        <div className={styles.heroFloat} aria-hidden="true">
          <div className={styles.floatCard}>
            <span className={styles.floatIcon}>🏔️</span>
            <div className={styles.floatText}>
              <strong>Mountain Goat</strong>
              <small>Achievement unlocked</small>
            </div>
            <span className={styles.floatCheck}>✓</span>
          </div>
          <div className={clsx(styles.floatCard, styles.floatCard2)}>
            <span className={styles.floatIcon}>🌍</span>
            <div className={styles.floatText}>
              <strong>Traveler I</strong>
              <small>Achievement unlocked</small>
            </div>
            <span className={styles.floatCheck}>✓</span>
          </div>
          <div className={clsx(styles.floatCard, styles.floatCard3)}>
            <span className={styles.floatIcon}>🌅</span>
            <div className={styles.floatText}>
              <strong>Golden Hour</strong>
              <small>Achievement unlocked</small>
            </div>
            <span className={styles.floatCheck}>✓</span>
          </div>
          <div className={clsx(styles.floatCard, styles.floatCard4)}>
            <span className={styles.floatIcon}>🚶</span>
            <div className={styles.floatText}>
              <strong>Night Walker</strong>
              <small>Achievement unlocked</small>
            </div>
            <span className={styles.floatCheck}>✓</span>
          </div>
          <div className={clsx(styles.floatCard, styles.floatCard5)}>
            <span className={styles.floatIcon}>✈️</span>
            <div className={styles.floatText}>
              <strong>Time Traveler</strong>
              <small>Achievement unlocked</small>
            </div>
            <span className={styles.floatCheck}>✓</span>
          </div>
        </div>
      </header>

      <main>

        {/* ── ACHIEVEMENTS ── */}
        <section className={styles.achievSection}>
          <div className="container">
            <div className={styles.sectionHead}>
              <span className={styles.sectionLabel}>{t.featuredLabel}</span>
              <h2 className={styles.sectionTitle}>{t.featuredTitle}</h2>
            </div>
            <div className={styles.achievGrid}>
              {t.achievements.map((a, i) => (
                <AchievementCard key={i} {...a} rarityLabel={t.rarityLabel[a.rarity]} />
              ))}
            </div>
            <div className={styles.achievMore}>
              <a
                href="https://farin25.github.io/real-live-achievement/docs/Achievments"
                target="_blank"
                rel="noopener noreferrer"
                className={styles.achievMoreLink}
              >
                {t.achievLink}
              </a>
            </div>
          </div>
        </section>

        {/* ── HOW IT WORKS ── */}
        <section className={styles.howSection}>
          <div className="container">
            <div className={styles.sectionHead}>
              <h2 className={styles.sectionTitle}>{t.howTitle}</h2>
            </div>
            <div className={styles.howGrid}>
              {t.how.map((h, i) => (
                <div key={i} className={styles.howCard}>
                  <span className={styles.howNum}>{h.num}</span>
                  <h3 className={styles.howCardTitle}>{h.title}</h3>
                  <p className={styles.howCardDesc}>{h.desc}</p>
                </div>
              ))}
            </div>
          </div>
        </section>

        {/* ── DEMO VIDEO ── */}
        <section id="demo" className={styles.demoSection}>
          <div className="container">
            <div className={styles.sectionHead}>
              <h2 className={styles.sectionTitle}>{t.videoTitle}</h2>
            </div>
            <div className={styles.videoFrame}>
              <iframe
                src="https://player.vimeo.com/video/1167330665"
                allow="autoplay; fullscreen; picture-in-picture"
                allowFullScreen
                title="Upmark Demo"
              />
            </div>
          </div>
        </section>

        {/* ── CTA ── */}
        <section className={styles.ctaSection}>
          <div className="container">
            <div className={styles.ctaBox}>
              <p className={styles.ctaRelease}>{t.ctaSub}</p>
              <h2 className={styles.ctaTitle}>{t.ctaTitle}</h2>
              <a
                href="https://farin25.github.io/real-live-achievement/docs/newsletter"
                target="_blank"
                rel="noopener noreferrer"
                className={styles.ctaBtn}
              >
                ✉ {t.ctaBtn}
              </a>
              <p className={styles.ctaBtnSub}>{t.ctaBtnSub}</p>
            </div>
          </div>
        </section>

      </main>
    </Layout>
  );
}