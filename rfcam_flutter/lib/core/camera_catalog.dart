import 'package:flutter/material.dart';

import 'film_effect.dart';
import 'film_textures.dart';

enum CamGroup { digital, video, vintage135, instant, accessory, legacy }

/// Shape archetype used by the procedural camera illustrations.
enum CamBody {
  compact,
  slr,
  slrGrip,
  rangefinder,
  cineCam,
  camcorder,
  flipCam,
  cassette,
  canister,
  projector,
  bottle,
  toyGun,
  toyCam,
  kino,
  instant,
  instantWide,
  filmStrip,
  triLens,
  disposable,
  halfFrame,
  sphere,
  frame,
  cardCompact,
  zoomCompact,
  bridge,
  waterproof,
  tlr,
  folder,
  boxCam,
  panorama,
  actionCube,
  foldSlr,
  filterDisc,
  flashUnit,
  domeLens,
}

@immutable
class CamVariant {
  const CamVariant(this.name, this.effect);
  final String name;
  final FilmEffect effect;
}

@immutable
class CameraProfile {
  const CameraProfile({
    required this.id,
    required this.name,
    required this.group,
    required this.body,
    required this.colors,
    required this.variants,
    this.badge,
    this.variantDesc,
    this.beta = false,
    this.flashDot = false,
    this.supportsVideo = false,
    this.plates,
  });

  final String id;
  final String name;

  /// The little coloured suffix after the name, e.g. the purple `R`.
  final String? badge;
  final CamGroup group;
  final CamBody body;
  final List<Color> colors;
  final List<CamVariant> variants;
  final String? variantDesc;
  final bool beta;
  final bool flashDot;
  final bool supportsVideo;

  /// Id of the film plate this camera prefers, from [FilmTextures]. Null
  /// means "pick by grain strength", which is what most cameras do.
  /// [FilmTextures.vhsSetId] means "cycle the VHS plates".
  final String? plates;

  bool get isAccessory => group == CamGroup.accessory;
  FilmEffect get effect => variants.first.effect;

  FilmEffect effectOf(String? variant) {
    if (variant == null) return effect;
    for (final v in variants) {
      if (v.name == variant) return v.effect;
    }
    return effect;
  }
}

/// Shorthands so the table below stays readable.
List<double> _m(List<List<double>> steps) => FilmEffect.compose(steps);
List<double> _tint(
  double r,
  double g,
  double b, {
  double lr = 0,
  double lg = 0,
  double lb = 0,
}) => FilmEffect.matTint(r, g, b, liftR: lr, liftG: lg, liftB: lb);
List<double> _sat(double s) => FilmEffect.matSaturation(s);
List<double> _con(double c) => FilmEffect.matContrast(c);
List<double> _ev(double s) => FilmEffect.matExposure(s);

class Cameras {
  Cameras._();

  static const _orange = Color(0xFFFF7A2F);
  static const _magenta = Color(0xFFFF3D8B);

  static final List<CameraProfile> all = [
    // ---------------------------------------------------------------- DIGITAL
    CameraProfile(
      id: 'fxn',
      name: 'FXN',
      badge: 'R',
      group: CamGroup.digital,
      body: CamBody.rangefinder,
      colors: const [Color(0xFF2B2B2E), Color(0xFF6E6E73), Color(0xFFE0382C)],
      flashDot: true,
      variantDesc:
          'So với FXN, FXN2 mang đến tông màu và màu sắc mượt mà hơn, cùng độ '
          'tương phản thấp hơn đôi chút.',
      variants: [
        CamVariant(
          'FXN',
          FilmEffect(
            matrix: _m([
              _tint(1.07, 1.0, 0.93, lr: 12, lg: 7, lb: 3),
              _con(0.95),
              _sat(1.06),
            ]),
            grain: 0.34,
            vignette: 0.30,
            leak: 0.45,
            leakColor: _orange,
            dust: 0.25,
            stamp: StampStyle.orangeRight,
          ),
        ),
        CamVariant(
          'FXN 2',
          FilmEffect(
            matrix: _m([
              _tint(1.04, 1.01, 0.98, lr: 16, lg: 13, lb: 10),
              _con(0.87),
              _sat(0.98),
            ]),
            grain: 0.20,
            vignette: 0.20,
            leak: 0.28,
            leakColor: _orange,
            dust: 0.15,
            stamp: StampStyle.orangeRight,
          ),
        ),
      ],
    ),
    CameraProfile(
      id: 'original',
      name: 'Original',
      group: CamGroup.digital,
      body: CamBody.compact,
      colors: const [Color(0xFF3A3A3C), Color(0xFF8E8E93)],
      variants: [CamVariant('Original', const FilmEffect())],
    ),
    CameraProfile(
      id: 'grd_r',
      plates: 'grain_03_s67',
      name: 'GRD',
      badge: 'R',
      group: CamGroup.digital,
      body: CamBody.cardCompact,
      colors: const [Color(0xFF1C1C1E), Color(0xFF48484A), Color(0xFF0A93E4)],
      variantDesc:
          'GRD cho ra sắc đen trắng tương phản cao, GRD Pos giữ lại một chút '
          'sắc độ màu để ảnh mềm hơn.',
      variants: [
        CamVariant(
          'GRD',
          FilmEffect(
            matrix: _m([_sat(0.0), _con(1.28), _ev(-0.05)]),
            grain: 0.42,
            vignette: 0.34,
          ),
        ),
        CamVariant(
          'GRD Pos',
          FilmEffect(
            matrix: _m([_sat(0.12), _con(1.18)]),
            grain: 0.32,
            vignette: 0.26,
          ),
        ),
      ],
    ),
    CameraProfile(
      id: 'ccd_r',
      plates: 'grain_01_ccd',
      name: 'CCD',
      badge: 'R',
      group: CamGroup.digital,
      body: CamBody.compact,
      colors: const [Color(0xFFC9C7C2), Color(0xFF6E6E73), Color(0xFFE0382C)],
      flashDot: true,
      variants: [
        CamVariant(
          'CCD',
          FilmEffect(
            matrix: _m([
              _tint(1.10, 1.02, 0.90, lb: -6),
              _con(1.16),
              _sat(1.24),
            ]),
            grain: 0.16,
            vignette: 0.44,
            bloom: 0.22,
            stamp: StampStyle.redSmall,
          ),
        ),
      ],
    ),
    CameraProfile(
      id: 's_classic',
      plates: 'grain_08_classic',
      name: 'S Classic',
      group: CamGroup.digital,
      body: CamBody.zoomCompact,
      colors: const [Color(0xFF9EA2A8), Color(0xFF2C2C2E)],
      flashDot: true,
      variants: [
        CamVariant(
          'S Classic',
          FilmEffect(
            matrix: _m([
              _ev(0.30),
              _con(1.24),
              _sat(1.10),
              _tint(1.05, 1.0, 0.98),
            ]),
            grain: 0.12,
            vignette: 0.52,
            bloom: 0.34,
            stamp: StampStyle.redSmall,
          ),
        ),
      ],
    ),
    CameraProfile(
      id: 'pqs',
      name: 'PQS',
      badge: 'R',
      group: CamGroup.digital,
      body: CamBody.waterproof,
      colors: const [Color(0xFF33C36B), Color(0xFF1C1C1E)],
      variants: [
        CamVariant(
          'PQS',
          FilmEffect(
            matrix: _m([
              _tint(0.95, 1.08, 0.99, lg: 8),
              _sat(1.15),
              _con(1.05),
            ]),
            grain: 0.24,
            vignette: 0.28,
            leak: 0.18,
            leakColor: Color(0xFF6BE39A),
          ),
        ),
      ],
    ),
    CameraProfile(
      id: 'collage',
      name: 'Collage',
      group: CamGroup.digital,
      body: CamBody.frame,
      colors: const [Color(0xFFEBD9C3), Color(0xFF8E6A4A)],
      variants: [
        CamVariant(
          'Collage',
          FilmEffect(
            matrix: _m([
              _tint(1.05, 1.0, 0.95, lr: 10, lg: 8, lb: 6),
              _con(0.94),
            ]),
            grain: 0.28,
            vignette: 0.22,
            aspect: 1.0,
          ),
        ),
      ],
    ),

    // ------------------------------------------------------------------ VIDEO
    CameraProfile(
      id: 'glow',
      name: 'Glow',
      group: CamGroup.video,
      body: CamBody.bottle,
      colors: const [Color(0xFFC94FE8), Color(0xFFE9E9EA)],
      supportsVideo: true,
      variants: [
        CamVariant(
          'Glow',
          FilmEffect(
            matrix: _m([
              _tint(1.08, 0.98, 1.12, lr: 14, lb: 20),
              _con(0.86),
              _sat(1.18),
            ]),
            grain: 0.18,
            bloom: 0.55,
            blurSigma: 0.9,
            leak: 0.35,
            leakColor: Color(0xFFC94FE8),
            vignette: 0.18,
          ),
        ),
      ],
    ),
    CameraProfile(
      id: 'vhs',
      plates: FilmTextures.vhsSetId,
      name: 'VHS',
      group: CamGroup.video,
      body: CamBody.cassette,
      colors: const [Color(0xFF1C1C1E), Color(0xFF3E7BD6)],
      supportsVideo: true,
      variants: [
        CamVariant(
          'VHS',
          FilmEffect(
            matrix: _m([
              _tint(1.02, 1.0, 1.06, lb: 10),
              _sat(0.88),
              _con(1.12),
            ]),
            grain: 0.55,
            scanlines: 1.0,
            chroma: 2.6,
            vignette: 0.38,
            showRec: true,
            aspect: 4 / 3,
          ),
        ),
      ],
    ),
    CameraProfile(
      id: 'eightmm',
      plates: 'grain_04_8mm',
      name: '8mm',
      group: CamGroup.video,
      body: CamBody.disposable,
      colors: const [Color(0xFFF2C230), Color(0xFF1C1C1E)],
      supportsVideo: true,
      variants: [
        CamVariant(
          '8mm',
          FilmEffect(
            matrix: _m([
              _tint(1.14, 1.0, 0.82, lr: 14, lg: 6),
              _con(1.06),
              _sat(0.94),
            ]),
            grain: 0.62,
            vignette: 0.5,
            dust: 0.7,
            leak: 0.4,
            leakColor: Color(0xFFFFB33D),
            aspect: 4 / 3,
          ),
        ),
      ],
    ),
    CameraProfile(
      id: 'original_v',
      plates: 'grain_05_super8',
      name: 'Original V',
      group: CamGroup.video,
      body: CamBody.actionCube,
      colors: const [Color(0xFF2C2C2E), Color(0xFFE0382C)],
      supportsVideo: true,
      flashDot: true,
      variants: [CamVariant('Original V', const FilmEffect(aspect: 16 / 9))],
    ),
    CameraProfile(
      id: 'v_classic',
      name: 'V Classic',
      group: CamGroup.video,
      body: CamBody.camcorder,
      colors: const [Color(0xFF1C1C1E), Color(0xFFD8D8DC)],
      supportsVideo: true,
      variants: [
        CamVariant(
          'V Classic',
          FilmEffect(
            matrix: _m([
              _tint(1.04, 1.0, 0.96, lr: 8, lg: 6, lb: 4),
              _sat(0.9),
              _con(1.08),
            ]),
            grain: 0.4,
            scanlines: 0.5,
            vignette: 0.34,
            chroma: 1.2,
            showRec: true,
            aspect: 4 / 3,
          ),
        ),
      ],
    ),
    CameraProfile(
      id: 'v_funs',
      name: 'V FunS',
      group: CamGroup.video,
      body: CamBody.toyGun,
      colors: const [Color(0xFFF2C230), Color(0xFFE0382C)],
      supportsVideo: true,
      variants: [
        CamVariant(
          'V FunS',
          FilmEffect(
            matrix: _m([_tint(1.12, 1.02, 0.86), _sat(1.3), _con(1.14)]),
            grain: 0.46,
            vignette: 0.46,
            leak: 0.5,
            leakColor: Color(0xFFFF5A2F),
            dust: 0.4,
          ),
        ),
      ],
    ),
    CameraProfile(
      id: 'kino',
      plates: 'grain_05_super8',
      name: 'Kino',
      group: CamGroup.video,
      body: CamBody.kino,
      colors: const [Color(0xFFF2F2F5), Color(0xFF1C1C1E)],
      supportsVideo: true,
      variants: [
        CamVariant(
          'Kino',
          FilmEffect(
            matrix: _m([
              _tint(0.97, 1.0, 1.08, lr: 6, lg: 8, lb: 12),
              _con(0.9),
              _sat(0.92),
            ]),
            grain: 0.3,
            vignette: 0.3,
            aspect: 2.35,
            blurSigma: 0.4,
          ),
        ),
      ],
    ),
    CameraProfile(
      id: 'sixteenmm',
      plates: 'grain_06_16mm',
      name: '16mm',
      group: CamGroup.video,
      body: CamBody.cineCam,
      colors: const [Color(0xFF2C2C2E), Color(0xFF6E6E73)],
      supportsVideo: true,
      variants: [
        CamVariant(
          '16mm',
          FilmEffect(
            matrix: _m([
              _tint(1.06, 1.0, 0.9, lr: 10, lg: 8),
              _con(1.02),
              _sat(0.96),
            ]),
            grain: 0.5,
            vignette: 0.42,
            dust: 0.55,
            aspect: 4 / 3,
          ),
        ),
      ],
    ),
    CameraProfile(
      id: 'slide_p',
      plates: 'grain_02_slide',
      name: 'Slide P',
      group: CamGroup.video,
      body: CamBody.projector,
      colors: const [Color(0xFFE9E9EA), Color(0xFF2C2C2E), Color(0xFFE0382C)],
      variants: [
        CamVariant(
          'Slide P',
          FilmEffect(
            matrix: _m([_sat(1.32), _con(1.2), _tint(1.03, 1.0, 1.02)]),
            grain: 0.18,
            vignette: 0.4,
            bloom: 0.2,
          ),
        ),
      ],
    ),
    CameraProfile(
      id: 'dcr',
      plates: 'grain_01_ccd',
      name: 'DCR',
      group: CamGroup.video,
      body: CamBody.canister,
      colors: const [Color(0xFFD8CBB0), Color(0xFF8E7A55)],
      variants: [
        CamVariant(
          'DCR',
          FilmEffect(
            matrix: _m([
              _tint(1.1, 1.0, 0.88, lr: 12, lg: 9, lb: 4),
              _con(0.96),
              _sat(1.02),
            ]),
            grain: 0.38,
            vignette: 0.32,
            leak: 0.3,
            leakColor: _orange,
            stamp: StampStyle.orangeRight,
          ),
        ),
      ],
    ),
    CameraProfile(
      id: 'dam',
      name: 'DAM',
      group: CamGroup.video,
      body: CamBody.flipCam,
      colors: const [Color(0xFF4A4A4E), Color(0xFFE0382C)],
      supportsVideo: true,
      variants: [
        CamVariant(
          'DAM',
          FilmEffect(
            matrix: _m([_sat(0.8), _con(1.18), _tint(0.98, 1.0, 1.04)]),
            grain: 0.44,
            scanlines: 0.32,
            vignette: 0.36,
          ),
        ),
      ],
    ),

    // ------------------------------------------------------------ VINTAGE 135
    CameraProfile(
      id: 'd_classic',
      plates: 'grain_08_classic',
      name: 'D Classic',
      group: CamGroup.vintage135,
      body: CamBody.slr,
      colors: const [Color(0xFFB9BCC1), Color(0xFF1C1C1E)],
      variants: [
        CamVariant(
          'D Classic',
          FilmEffect(
            matrix: _m([
              _tint(1.04, 1.0, 0.94, lr: 9, lg: 8, lb: 6),
              _con(0.98),
            ]),
            grain: 0.32,
            vignette: 0.3,
            stamp: StampStyle.orangeRight,
          ),
        ),
      ],
    ),
    CameraProfile(
      id: 'gr_f',
      name: 'GR F',
      group: CamGroup.vintage135,
      body: CamBody.slrGrip,
      colors: const [Color(0xFF1C1C1E), Color(0xFF3A3A3C)],
      variants: [
        CamVariant(
          'GR F',
          FilmEffect(
            matrix: _m([_tint(1.0, 1.01, 1.05, lb: 8), _con(1.1), _sat(0.86)]),
            grain: 0.4,
            vignette: 0.36,
          ),
        ),
      ],
    ),
    CameraProfile(
      id: 'ct2f',
      name: 'CT2F',
      group: CamGroup.vintage135,
      body: CamBody.folder,
      colors: const [Color(0xFFE4CDB0), Color(0xFF2C2C2E)],
      variants: [
        CamVariant(
          'CT2F',
          FilmEffect(
            matrix: _m([
              _tint(1.05, 1.02, 0.94, lr: 10, lg: 10, lb: 8),
              _con(0.92),
              _sat(1.08),
            ]),
            grain: 0.3,
            vignette: 0.26,
            leak: 0.22,
            leakColor: _orange,
            stamp: StampStyle.redSmall,
          ),
        ),
      ],
    ),
    CameraProfile(
      id: 'gt2f',
      name: 'GT2F',
      group: CamGroup.vintage135,
      body: CamBody.bridge,
      colors: const [Color(0xFFC7C9CE), Color(0xFF2C2C2E)],
      variants: [
        CamVariant(
          'GT2F',
          FilmEffect(
            matrix: _m([
              _tint(1.0, 1.03, 1.02, lg: 8, lb: 8),
              _con(0.95),
              _sat(1.05),
            ]),
            grain: 0.28,
            vignette: 0.24,
            stamp: StampStyle.redSmall,
          ),
        ),
      ],
    ),
    CameraProfile(
      id: 'd3d',
      name: 'D3D',
      group: CamGroup.vintage135,
      body: CamBody.triLens,
      colors: const [Color(0xFFE0592C), Color(0xFF2C2C2E)],
      variants: [
        CamVariant(
          'D3D',
          FilmEffect(
            matrix: _m([_sat(1.16), _con(1.06)]),
            grain: 0.3,
            chroma: 4.5,
            vignette: 0.3,
          ),
        ),
      ],
    ),
    CameraProfile(
      id: 'ne135',
      plates: 'grain_06_16mm',
      name: '135 NE',
      group: CamGroup.vintage135,
      body: CamBody.filmStrip,
      colors: const [Color(0xFF2C2C2E), Color(0xFF6E8FB0)],
      variants: [
        CamVariant(
          '135 NE',
          FilmEffect(
            matrix: _m([_tint(0.98, 1.02, 1.1, lb: 14), _con(0.9), _sat(0.95)]),
            grain: 0.36,
            vignette: 0.3,
            negative: true,
          ),
        ),
      ],
    ),
    CameraProfile(
      id: 'sr135',
      plates: 'grain_03_s67',
      name: '135 SR',
      group: CamGroup.vintage135,
      body: CamBody.filmStrip,
      colors: const [Color(0xFFF2C230), Color(0xFF2C2C2E)],
      variants: [
        CamVariant(
          '135 SR',
          FilmEffect(
            matrix: _m([_tint(1.12, 1.0, 0.86, lr: 12), _sat(1.12)]),
            grain: 0.42,
            vignette: 0.34,
            dust: 0.4,
            stamp: StampStyle.orangeRight,
          ),
        ),
      ],
    ),
    CameraProfile(
      id: 'd_funs',
      name: 'D FunS',
      group: CamGroup.vintage135,
      body: CamBody.toyCam,
      colors: const [Color(0xFFF2C230), Color(0xFFE0382C)],
      variants: [
        CamVariant(
          'D FunS',
          FilmEffect(
            matrix: _m([_tint(1.1, 1.04, 0.88), _sat(1.28), _con(1.1)]),
            grain: 0.44,
            vignette: 0.44,
            leak: 0.45,
            leakColor: Color(0xFFFF7A2F),
            dust: 0.35,
          ),
        ),
      ],
    ),
    CameraProfile(
      id: 'ir',
      name: 'IR',
      group: CamGroup.vintage135,
      body: CamBody.toyCam,
      colors: const [Color(0xFFE0382C), Color(0xFF1C1C1E)],
      variants: [
        CamVariant(
          'IR',
          FilmEffect(
            matrix: _m([
              _tint(1.25, 0.82, 1.1, lr: 18, lb: 10),
              _sat(1.35),
              _con(1.05),
            ]),
            grain: 0.34,
            vignette: 0.36,
            leak: 0.3,
            leakColor: _magenta,
          ),
        ),
      ],
    ),
    CameraProfile(
      id: 'classic_u',
      name: 'Classic U',
      group: CamGroup.vintage135,
      body: CamBody.slr,
      colors: const [Color(0xFF2C2C2E), Color(0xFFB9BCC1)],
      variants: [
        CamVariant(
          'Classic U',
          FilmEffect(
            matrix: _m([
              _tint(1.02, 1.0, 0.97, lr: 12, lg: 11, lb: 9),
              _con(0.88),
              _sat(0.94),
            ]),
            grain: 0.3,
            vignette: 0.28,
          ),
        ),
      ],
    ),
    CameraProfile(
      id: 'dqs',
      name: 'DQS',
      group: CamGroup.vintage135,
      body: CamBody.tlr,
      colors: const [Color(0xFF1F9E62), Color(0xFF2C2C2E)],
      variants: [
        CamVariant(
          'DQS',
          FilmEffect(
            matrix: _m([
              _tint(0.96, 1.06, 0.98, lg: 10),
              _sat(1.1),
              _con(1.04),
            ]),
            grain: 0.3,
            vignette: 0.3,
          ),
        ),
      ],
    ),
    CameraProfile(
      id: 'fqs',
      name: 'FQS',
      badge: 'R',
      group: CamGroup.vintage135,
      body: CamBody.panorama,
      colors: const [Color(0xFF7BE04A), Color(0xFF1C1C1E)],
      variants: [
        CamVariant(
          'FQS',
          FilmEffect(
            matrix: _m([_tint(0.94, 1.1, 0.94, lg: 12), _sat(1.2), _con(1.08)]),
            grain: 0.36,
            vignette: 0.32,
            leak: 0.24,
            leakColor: Color(0xFF7BE04A),
          ),
        ),
      ],
    ),
    CameraProfile(
      id: 'golf',
      name: 'Golf',
      group: CamGroup.vintage135,
      body: CamBody.boxCam,
      colors: const [Color(0xFF2E8B57), Color(0xFFE9E9EA)],
      variants: [
        CamVariant(
          'Golf',
          FilmEffect(
            matrix: _m([_tint(0.98, 1.05, 0.96, lg: 6), _sat(1.06)]),
            grain: 0.26,
            vignette: 0.26,
          ),
        ),
      ],
    ),
    CameraProfile(
      id: 'cpm3s',
      plates: 'grain_03_s67',
      name: 'CPM3S',
      group: CamGroup.vintage135,
      body: CamBody.rangefinder,
      colors: const [Color(0xFF8E8E93), Color(0xFF1C1C1E)],
      variants: [
        CamVariant(
          'CPM3S',
          FilmEffect(
            matrix: _m([_sat(0.0), _con(1.14), _tint(1.02, 1.0, 0.98)]),
            grain: 0.46,
            vignette: 0.38,
            dust: 0.3,
          ),
        ),
      ],
    ),
    CameraProfile(
      id: 'd_half',
      plates: 'grain_03_s67',
      name: 'D Half',
      group: CamGroup.vintage135,
      body: CamBody.halfFrame,
      colors: const [Color(0xFF2C2C2E), Color(0xFFE9E9EA)],
      variants: [
        CamVariant(
          'D Half',
          FilmEffect(
            matrix: _m([
              _tint(1.05, 1.0, 0.95, lr: 10, lg: 8, lb: 6),
              _con(0.95),
            ]),
            grain: 0.34,
            vignette: 0.3,
            halfFrame: true,
            aspect: 3 / 2,
          ),
        ),
      ],
    ),
    CameraProfile(
      id: 'd_slide',
      plates: 'grain_02_slide',
      name: 'D Slide',
      group: CamGroup.vintage135,
      body: CamBody.frame,
      colors: const [Color(0xFFE0382C), Color(0xFFE9E9EA)],
      variants: [
        CamVariant(
          'D Slide',
          FilmEffect(
            matrix: _m([_sat(1.4), _con(1.24), _tint(1.02, 1.0, 1.04)]),
            grain: 0.2,
            vignette: 0.42,
            bloom: 0.18,
          ),
        ),
      ],
    ),
    CameraProfile(
      id: 'ofm_r',
      name: 'OFM',
      badge: 'R',
      group: CamGroup.vintage135,
      body: CamBody.foldSlr,
      colors: const [Color(0xFF1C1C1E), Color(0xFF0A93E4)],
      beta: true,
      variants: [
        CamVariant(
          'OFM',
          FilmEffect(
            matrix: _m([_tint(1.0, 1.0, 1.06, lb: 10), _con(0.94), _sat(0.98)]),
            grain: 0.3,
            vignette: 0.3,
          ),
        ),
      ],
    ),

    // ---------------------------------------------------------------- INSTANT
    CameraProfile(
      id: 'inst_c',
      plates: 'grain_07_instant',
      name: 'Inst C',
      group: CamGroup.instant,
      body: CamBody.instant,
      colors: const [Color(0xFFE9E9EA), Color(0xFFE0382C)],
      variants: [
        CamVariant(
          'Inst C',
          FilmEffect(
            matrix: _m([
              _tint(1.06, 1.0, 0.96, lr: 16, lg: 14, lb: 12),
              _con(0.86),
              _sat(0.96),
            ]),
            grain: 0.24,
            vignette: 0.2,
            aspect: 1.0,
          ),
        ),
      ],
    ),
    CameraProfile(
      id: 'inst_sq',
      plates: 'grain_07_instant',
      name: 'Inst SQ',
      group: CamGroup.instant,
      body: CamBody.instantWide,
      colors: const [Color(0xFF2C2C2E), Color(0xFF8E8E93)],
      variants: [
        CamVariant(
          'Inst SQ',
          FilmEffect(
            matrix: _m([
              _tint(1.02, 1.0, 1.03, lr: 14, lg: 14, lb: 16),
              _con(0.88),
              _sat(0.9),
            ]),
            grain: 0.22,
            vignette: 0.22,
            aspect: 1.0,
          ),
        ),
      ],
    ),
    CameraProfile(
      id: 'inst_sqc',
      plates: 'grain_07_instant',
      name: 'Inst SQC',
      group: CamGroup.instant,
      body: CamBody.instant,
      colors: const [Color(0xFFE4CDB0), Color(0xFF2C2C2E)],
      variants: [
        CamVariant(
          'Inst SQC',
          FilmEffect(
            matrix: _m([
              _tint(1.08, 1.0, 0.92, lr: 15, lg: 12, lb: 8),
              _con(0.9),
              _sat(1.08),
            ]),
            grain: 0.26,
            vignette: 0.24,
            aspect: 1.0,
          ),
        ),
      ],
    ),
    CameraProfile(
      id: 'paf_r',
      name: 'PAF',
      badge: 'R',
      group: CamGroup.instant,
      body: CamBody.foldSlr,
      colors: const [Color(0xFFE0592C), Color(0xFF2C2C2E)],
      beta: true,
      variants: [
        CamVariant(
          'PAF',
          FilmEffect(
            matrix: _m([_tint(1.1, 1.0, 0.9, lr: 12), _con(0.94), _sat(1.14)]),
            grain: 0.3,
            vignette: 0.3,
            leak: 0.3,
            leakColor: _orange,
            aspect: 1.0,
          ),
        ),
      ],
    ),

    // -------------------------------------------------------------- ACCESSORY
    CameraProfile(
      id: 'nd',
      name: 'ND Filter',
      group: CamGroup.accessory,
      body: CamBody.filterDisc,
      colors: const [Color(0xFF3A3A3C), Color(0xFF1C1C1E)],
      variants: [CamVariant('ND Filter', const FilmEffect())],
    ),
    CameraProfile(
      id: 'fisheye_f',
      name: 'Fisheye F',
      group: CamGroup.accessory,
      body: CamBody.sphere,
      colors: const [Color(0xFF6B3AE0), Color(0xFF1C1C1E)],
      variants: [CamVariant('Fisheye F', const FilmEffect())],
    ),
    CameraProfile(
      id: 'fisheye_w',
      name: 'Fisheye W',
      group: CamGroup.accessory,
      body: CamBody.domeLens,
      colors: const [Color(0xFF16374E), Color(0xFF0B1620)],
      variants: [CamVariant('Fisheye W', const FilmEffect())],
    ),
    CameraProfile(
      id: 'prism',
      name: 'Prism',
      group: CamGroup.accessory,
      body: CamBody.sphere,
      colors: const [Color(0xFF2A2A2E), Color(0xFF9E7BE0)],
      variants: [CamVariant('Prism', const FilmEffect())],
    ),
    CameraProfile(
      id: 'flash_c',
      name: 'Flash C',
      group: CamGroup.accessory,
      body: CamBody.flashUnit,
      colors: const [Color(0xFF8E1A12), Color(0xFF3A0A06)],
      variants: [CamVariant('Flash C', const FilmEffect())],
    ),
    CameraProfile(
      id: 'star',
      name: 'Star',
      group: CamGroup.accessory,
      body: CamBody.sphere,
      colors: const [Color(0xFFC94FE8), Color(0xFF6B1A8E)],
      variants: [CamVariant('Star', const FilmEffect())],
    ),
  ];

  static List<CameraProfile> get shooters =>
      all.where((c) => !c.isAccessory).toList(growable: false);

  static List<CameraProfile> get accessories =>
      all.where((c) => c.isAccessory).toList(growable: false);

  static CameraProfile byId(String id) =>
      tryById(id) ?? all.firstWhere((c) => c.id == 'fxn');

  static CameraProfile? tryById(String id) {
    for (final c in all) {
      if (c.id == id) return c;
    }
    return null;
  }

  static List<CameraProfile> group(CamGroup g) =>
      all.where((c) => c.group == g).toList(growable: false);

  static const groupTitles = <CamGroup, String>{
    CamGroup.digital: 'DIGITAL',
    CamGroup.video: 'VIDEO',
    CamGroup.vintage135: 'VINTAGE 135',
    CamGroup.instant: 'INSTANT',
    CamGroup.accessory: 'ACCESSORY',
    CamGroup.legacy: 'CAMERA ĐỜI CŨ',
  };

  /// Order used by the two-row horizontal strip in the quick selector.
  static List<CameraProfile> get quickStrip {
    const order = [
      'glow',
      'vhs',
      'eightmm',
      'original_v',
      'v_classic',
      'v_funs',
      'kino',
      'sixteenmm',
      'slide_p',
      'dcr',
      'ir',
      'd_half',
      'inst_sqc',
      'd_slide',
      's_classic',
      'grd_r',
      'ccd_r',
      'dam',
      'd_classic',
      'gr_f',
      'ct2f',
      'd3d',
      'ne135',
      'd_funs',
      'classic_u',
      'dqs',
      'golf',
      'cpm3s',
      'sr135',
      'inst_c',
      'inst_sq',
      'collage',
      'original',
      'gt2f',
      'fqs',
      'paf_r',
      'ofm_r',
      'pqs',
      'fxn',
    ];
    final out = <CameraProfile>[];
    for (final id in order) {
      final c = tryById(id);
      if (c != null) out.add(c);
    }
    for (final c in shooters) {
      if (!out.contains(c)) out.add(c);
    }
    return out;
  }

  /// The aspect chips shown under "Tỷ Lệ".
  static const ratios = <String, double>{
    '1:1': 1.0,
    '5:4': 5 / 4,
    '4:3': 4 / 3,
    '7:5': 7 / 5,
    '3:2': 3 / 2,
    '16:9': 16 / 9,
    '2.35:1': 2.35,
  };

  /// Maps a [FilmEffect] back to the plate its camera asked for.
  ///
  /// The painter and the bake only ever receive a [FilmEffect], never the
  /// [CameraProfile] it came from, so the link has to be rebuilt here. The key
  /// deliberately uses only the fields an accessory never rewrites (grain,
  /// leak, dust, scanlines, framing, stamp) — that way `withAccessory` copies
  /// still resolve to their camera's plate instead of silently falling back.
  static String? plateSetFor(FilmEffect e) => _plateIndex[_sig(e)];

  static final Map<String, String> _plateIndex = {
    for (final c in all)
      if (c.plates != null)
        for (final v in c.variants) _sig(v.effect): c.plates!,
  };

  static String _sig(FilmEffect e) =>
      '${e.grain.toStringAsFixed(3)}|${e.leak.toStringAsFixed(3)}|'
      '${e.dust.toStringAsFixed(3)}|${e.scanlines.toStringAsFixed(3)}|'
      '${e.aspect.toStringAsFixed(4)}|${e.stamp.index}|${e.halfFrame}|'
      '${e.negative}|${e.showRec}|${e.leakColor.toARGB32()}';
}
