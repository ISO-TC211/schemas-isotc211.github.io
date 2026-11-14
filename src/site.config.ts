import type { SiteConfig } from '@isotc211/astro-ui'

export const siteConfig: SiteConfig = {
  title: 'ISO/TC 211 Implementation Schemas',
  titleHtml: 'ISO/TC&nbsp;211 Implementation Schemas',
  brandSub: 'Harmonized Resources Maintenance Agency',
  description: 'Implementation schemas for geographic information technology from ISO/TC 211 Geographic information/Geomatics.',
  nav: [
    { title: 'About', url: '/about/' },
    { title: 'Resources', url: '/resources/' },
    { title: 'Codelists', url: '/resources/codelists/' },
    { title: 'Docs', url: '/docs/' },
    { title: 'News', url: '/news/' },
  ],
  committee: {
    id: 211,
    name: 'Geographic information/Geomatics',
    home: 'https://committee.iso.org/home/tc211',
  },
  footerLinks: [
    { title: 'Main Site', url: 'https://www.isotc211.org' },
    { title: 'Standards', url: 'https://standards.isotc211.org/' },
    { title: 'Geodetic Registry', url: 'https://geodetic.isotc211.org/' },
    { title: 'UML Models', url: 'http://iso.sparxcloud.com/index.php' },
    { title: 'Terminology', url: 'https://isotc211.geolexica.org/' },
    { title: 'Ontologies', url: 'https://def.isotc211.org' },
  ],
  social: {
    links: [
      { url: 'https://twitter.com/ISOTC211' },
      { url: 'https://github.com/ISO-TC211' },
    ],
  },
}
