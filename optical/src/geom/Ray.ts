/**
 * Created by hanyeah on 2019/7/11.
 */
namespace hanyeah.optical.geom {
  import HObject = hanyeah.electricity.HObject;
  export class Ray extends HObject{
    public sp: Point;
    public distance: number;
    private _dir: Point;

    constructor(sp: Point = null, dir: Point = null) {
      super();
      this.sp = sp ? sp.clone() : new Point(0, 0);
      this.dir = dir ? dir.clone() : new Point(1, 0);
    }

    public set dir(value: Point) {
      this._dir = value.clone();
      this._dir.normalize();
    }

    public get dir(): Point {
      return this._dir;
    }

    public clone(): Ray {
      return new Ray(this.sp, this.dir);
    }

    public getPoint(t: number): Point {
      return new Point(this.sp.x + t * this._dir.x, this.sp.y + t * this._dir.y);
    }

    public getPoint2(t: number, p: Point): void {
      p.x = this.sp.x + t * this._dir.x;
      p.y = this.sp.y + t * this._dir.y;
    }

    public intersectT(ray: Ray): number[] {
      const result: number[] = [];
      const d12: number = this.dir.cross(ray.dir);
      if (d12 !== 0) {
        const o: Point = Point.sub(ray.sp, this.sp);
        const dco: number = this.dir.cross(o);
        const t: number = dco / d12;
        if (t > 0) {
          result.push(t);
        }
      }
      return result;
    }

    public getNormal(p: Point, normalize: boolean = false): Point {
      const normal = Point.rotNeg90(this.dir);
      if (normalize) {
        normal.normalize(1);
      }
      return normal;
    }

  }
}
