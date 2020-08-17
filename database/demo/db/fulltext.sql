DROP TABLE IF EXISTS `documents`;

create table `documents` (
  `id` INT unsigned NOT NULL AUTO_INCREMENT,
  `content` text,
  PRIMARY KEY (`id`),
  FULLTEXT(`content`) WITH PARSER ngram
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT INTO `documents` (`content`)
VALUES
  ('春はあけぼの。やうやう白くなりゆく山際、少し明かりて、紫だちたる雲の細くたなびきたる。'),
  ('夏は夜。月のころはさらなり、闇もなほ、蛍の多く飛びちがひたる。また、ただ一つ二つなど、ほのかにうち光て行くもをかし。雨など降るもをかし。'),
  ('秋は夕暮れ。夕日の差して山の端いと近うなりたるに、烏の寝所へ行くとて、三つ四つ、二つ三つなど飛び急ぐさへあはれなり。まいて雁などの連ねたるが、いと小さく見ゆるは、いとをかし。日入り果てて、風の音、虫の音など、はた言ふべきにあらず。'),
  ('冬はつとめて。雪の降りたるは言ふべきにもあらず、霜のいと白きも、またさらでもいと寒きに、火など急ぎおこして、炭持て渡るも、いとつきづきし。昼になりて、ぬるくゆるびもていけば、火桶の火も、白き灰がちになりてわろし。');
