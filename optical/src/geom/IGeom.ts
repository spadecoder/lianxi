/**
 * Created by hanyeah on 2019/7/11.
 */
namespace hanyeah.optical.geom {
  export interface IGeom {

    clone(): IGeom;

    intersect(ray: Ray): IntersectResult;

    getNormal(p: Point, normalize: boolean): Point;

    intersectT(ray: Ray): number[];

    containsPoint(p: Point): number;

  }
}
