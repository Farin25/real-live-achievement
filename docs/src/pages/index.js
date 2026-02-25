// src/pages/index.tsx  (oder .js)
import React from 'react';
import clsx from 'clsx';
import Link from '@docusaurus/Link';
import useDocusaurusContext from '@docusaurus/useDocusaurusContext';
import Layout from '@theme/Layout';
import styles from './index.module.css';

function HomepageHeader() {
  return (
    <header className={styles.hero}>
      <div className="container">
        <h1 className={styles.title}>
          RealLife<br />Achievements
        </h1>
        <p className={styles.subtitle}>
          Dein echtes Leben wird zum Spiel.<br />
          Sammle echte Abenteuer – nicht nur Punkte.
        </p>
        <div className={styles.buttons}>
          <Link
            className={styles.ctaPrimary}
            to="/docs/intro">
            Jetzt App entdecken 🚀
          </Link>
          <Link
            className={styles.ctaSecondary}
            to="#demo">
            Video ansehen
          </Link>
        </div>
      </div>
    </header>
  );
}

export default function Home() {
  const {siteConfig} = useDocusaurusContext();

  return (
    <Layout title={siteConfig.title} description="Achievement system for real-world events">
      <HomepageHeader />

      <main>
        {/* Intro */}
        <section className={styles.intro}>
          <div className="container">
            <h2>Verwandle dein Leben in ein Spiel</h2>
            <p>
              Upmark belohnt dich für echtes Leben. Gehe raus, entdecke die Welt und sammle Achievements wie in deinem Lieblingsspiel – nur besser.
            </p>
          </div>
        </section>

        {/* Features */}
        <section className={styles.features}>
          <div className="container">
            <div className="row">
              <div className={clsx('col col--4', styles.featureCol)}>
                <div className={styles.featureCard}>
                  <svg className={styles.featureIcon} viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.6">
                    <path d="M12 2L2 7l10 5 10-5-10-5zM2 17l10 5 10-5M2 12l10 5 10-5" />
                    <circle cx="12" cy="12" r="3" />
                  </svg>
                  <h3>Entdecker werden</h3>
                  <p>Neue Orte, neue Länder, neue Stories. Von „First Summit“ bis „Unknown Chunk Loaded“.</p>
                </div>
              </div>

              <div className={clsx('col col--4', styles.featureCol)}>
                <div className={styles.featureCard}>
                  <svg className={styles.featureIcon} viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.6">
                    <path d="M4 4h16v16H4z" />
                    <path d="M4 8h16M8 4v16" />
                  </svg>
                  <h3>Aktiv bleiben</h3>
                  <p>Wandern, Campen, Trailrunning – hol dir „Bushcamper“, „Epic Hike“ oder „1000 km Club“.</p>
                </div>
              </div>

              <div className={clsx('col col--4', styles.featureCol)}>
                <div className={styles.featureCard}>
                  <svg className={styles.featureIcon} viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.6">
                    <circle cx="12" cy="12" r="10" />
                    <path d="M12 8v4l3 3" />
                  </svg>
                  <h3>Momente erleben</h3>
                  <p>Golden Hour, Sternenhimmel, Gewitter – „Weather Warrior“, „Goblin Mode“, „Midnight Magic“.</p>
                </div>
              </div>
            </div>
          </div>
        </section>

        {/* Demo Video */}
        <section id="demo" className={styles.demoSection}>
          <div className="container">
            <h2 className={styles.demoTitle}>So funktioniert Upmark</h2>
            <div className={styles.videoWrapper}>
              <iframe
                src="https://player.vimeo.com/video/1167330665"
                allow="autoplay; fullscreen; picture-in-picture"
                allowFullScreen
                title="Upmark Demo"
              />
            </div>
          </div>
        </section>

        {/* Achievements */}
        <section className={styles.achievements}>
          <div className="container">
            <h2>Beliebte Achievements</h2>
            <div className={styles.achievementGrid}>
              {[
                { title: "Tutorial Finished", desc: " Werde 18 Jahre alt" },
                { title: "Travler I", desc: " Besuche 5 Länder" },
                { title: "Early Bird", desc: " 200+ Schritte vor 5 Uhr" },
                { title: "Offline Mode", desc: " 1 Tag ohne Internet" },
                { title: "Golden Hour", desc: " Sonnenuntergang erleben" },
                { title: "Bushcamper", desc: " Nacht im Wald" },
              ].map((a, i) => (
                <div key={i} className={styles.achievementCard}>
                  <div className={styles.badge}>🏆</div>
                  <strong>{a.title}</strong>
                  <span>{a.desc}</span>
                </div>
              ))}
            </div>
          </div>
        </section>

        {/* Release CTA */}
        <section className={styles.ctaSection}>
          <div className="container">
            <h2>Release: Juli 2026</h2>
            <p>Android • Wear OS • Play Store</p>
            <div className={styles.ctaButtons}>
              <a href="https://discord.gg/6J4Ws5ckYX" target="_blank" className={styles.ctaSecondary}>
                Discord beitreten
              </a>
            </div>
          </div>
        </section>
      </main>
    </Layout>
  );
}