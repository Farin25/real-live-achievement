import React from 'react';
import clsx from 'clsx';
import Link from '@docusaurus/Link';
import useDocusaurusContext from '@docusaurus/useDocusaurusContext';
import Layout from '@theme/Layout';
import styles from './index.module.css';

function HomepageHeader() {
  const {siteConfig} = useDocusaurusContext();
  return (
    <header className={clsx('hero hero--primary', styles.heroBanner)}>
      <div className="container">
        <h1 className="hero__title">RealLife Achievements</h1>
        <p className="hero__subtitle">Achievement system for real-world events 🏆</p>
        <div className={styles.buttons}>
          <Link
            className="button button--secondary button--lg"
            to="/docs/intro">
            Entdecke die App 🚀
          </Link>
        </div>
      </div>
    </header>
  );
}

export default function Home() {
  const {siteConfig} = useDocusaurusContext();
  return (
    <Layout
      title={`${siteConfig.title}`}
      description="Achievement system for real-world events">
      <HomepageHeader />
      <main>
        <section className={styles.features}>
          <div className="container">
            <div className="row">
              <div className="col col--12">
                <div className="text--center">
                  <h2>Verwandle dein Leben in ein Spiel 🎮</h2>
                  <p>
                    Upmark motiviert dich, wieder mehr rauszugehen und echte Abenteuer zu erleben. 
                    Sammle Achievements wie in Videospielen – aber im echten Leben!
                  </p>
                </div>
              </div>
            </div>
            
            <div className="row">
              <div className="col col--4">
                <div className="text--center">
                  <div className={styles.featureIcon}>🗺️</div>
                  <h3>Entdecker werden</h3>
                  <p>
                    Bereise neue Länder, erkunde unbekannte Orte und sammle 
                    Travel-Achievements wie "Traveler I-III" oder "Unknown Chunk Loaded"
                  </p>
                </div>
              </div>
              
              <div className="col col--4">
                <div className="text--center">
                  <div className={styles.featureIcon}>🥾</div>
                  <h3>Aktiv bleiben</h3>
                  <p>
                    Wandere neue Strecken, campe in der Wildnis und hole dir 
                    "Wanderer", "Bushcamper" oder "Adventure" Achievements
                  </p>
                </div>
              </div>
              
              <div className="col col--4">
                <div className="text--center">
                  <div className={styles.featureIcon}>🌅</div>
                  <h3>Momente erleben</h3>
                  <p>
                    Erlebe die Golden Hour, trotze dem Wetter oder gehe bei Mondschein 
                    raus – für "Golden Hour", "Weather Resistant" und "Goblin Mode"
                  </p>
                </div>
              </div>
            </div>

            <div className="row margin-top--lg">
              <div className="col col--6">
                {/* --- Neuer, ansprechender Demo-Bereich mit Vimeo-Video --- */}
                <div className={styles.demoSectionEnhanced}>
                  <h3>🎥 Demo ansehen</h3>
                  <p className={styles.demoText}>
                    Schau dir das Konzeptvideo an und erlebe, wie Upmark funktioniert!
                  </p>
                  <div className={styles.videoWrapper}>
                    <iframe
                      src="https://player.vimeo.com/video/1167330665"
                      className={styles.responsiveVideo}
                      frameBorder="0"
                      allow="autoplay; fullscreen; picture-in-picture"
                      allowFullScreen
                      title="Demo Video"
                    />
                  </div>
                </div>
              </div>
              
              <div className="col col--6">
                <div className={styles.releaseSection}>
                  <h3>📅 Release: Juli 2026</h3>
                  <p>
                    Verfügbar für Android als APK und im Play Store. 
                    Auch für Wear OS geplant!
                  </p>
                  <Link
                    className="button button--secondary"
                    href="https://discord.gg/6J4Ws5ckYX">
                    Discord beitreten
                  </Link>
                </div>
              </div>
            </div>

            <div className="row margin-top--lg">
              <div className="col col--12">
                <div className="text--center">
                  <h3>🏆 Beliebte Achievements</h3>
                  <div className={styles.achievementGrid}>
                    <div className={styles.achievement}>
                      <strong>Tutorial Finished</strong> – Werde 18 Jahre alt
                    </div>
                    <div className={styles.achievement}>
                      <strong>Touch Grass</strong> – Verbringe 2+ Stunden draußen
                    </div>
                    <div className={styles.achievement}>
                      <strong>Early Bird</strong> – 200+ Schritte vor 5 Uhr morgens
                    </div>
                    <div className={styles.achievement}>
                      <strong>Offline Mode</strong> – 1 Tag ohne Internet
                    </div>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </section>
      </main>
    </Layout>
  );
}
